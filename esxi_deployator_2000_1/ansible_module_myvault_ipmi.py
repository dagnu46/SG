#!/usr/bin/python

import requests
import json
from sg_cacert_file import load_sg_certs
from ansible.module_utils.basic import *

def main():

    # fields = {
    #     "myvault_pathname_local": {"required": True, "type": "str"},
    #     "myvault_user_local": {"required": True, "type": "str"}
    # }

    # module_args = dict(
    #     myvault_pathname_local=dict(type='str', required=True)
    # )

    # module = AnsibleModule(argument_spec=module_args)

    # print(module)

    load_sg_certs()

    VAULT_URL = 'https://vault.cloud.socgen/'
    VAULT_NAMESPACE = 'myVault/VPS_283757_PRD_myVault_VPS'

    # Just for the example credentials are hardcoded
    approle_id = '9424e051-8d1e-bf04-b55e-cf147fc3476f'
    secret_id = 'a12f3d1a-af50-aad0-dc66-f90cda6f0e3c'

    data = {
        "role_id": approle_id,
        "secret_id": secret_id
    }

    response = requests.post(
        url=VAULT_URL + "v1/auth/approle/login",
        headers={'X-Vault-Namespace': VAULT_NAMESPACE,
                'content-type': 'application/json'},
        data=json.dumps(data))

    # Vault token will be response.json()['auth']['client_token']
    print(response.json()['auth']['client_token'])

    myvault_pathname_local='kv_vps/data/[IDRAC][ILO][RCR][GCR][DWS]ccsrac'
    myvault_user_local = 'ccsrac'

    response2 = requests.get(
        url=VAULT_URL + "v1/" + myvault_pathname_local,
        headers={'X-Vault-Namespace': VAULT_NAMESPACE,
                'content-type': 'application/json',
                'X-Vault-Token': response.json()['auth']['client_token']})

    # Your secret "guide_demo"
    # print(response2.json()['data'])
    print(response2.json()['data']['data']['ccsrac'])


    # module.exit_json(changed=False, resultt=(response2.json()['data']['data'][myvault_user_local]))  

if __name__ == "__main__": 
    main()
