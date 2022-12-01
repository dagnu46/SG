#!/bin/bash -e

if [ -z ${INSTALL_DIR} ]; then
  INSTALL_DIR="${HOME}/tools/python"
fi

#Allow to install a specific version of Conda if specified, else use the latest
if [ $# -eq 0 ]; then
  CONDA_VERSION="latest"
else
  CONDA_VERSION="$1"
fi

INTERPRETER='Miniconda'
VERSION='3'
ARCH='x86_64'

PACKAGE_URL="https://cdp-artifactory.fr.world.socgen/artifactory/ext-${INTERPRETER,,}-proxy/${INTERPRETER}${VERSION}-${CONDA_VERSION}-Linux-${ARCH}.sh"

CONF_DIR=$HOME
PIP_CONF_DIR="${CONF_DIR}/.config/pip"

# Download and install miniconda in ~/tools/python
INSTALL_FILE=$(mktemp -t minicondaXXXXXX.sh)
curl --silent -k ${PACKAGE_URL} -o ${INSTALL_FILE}
chmod 755 ${INSTALL_FILE}
mkdir -p ${INSTALL_DIR}
${INSTALL_FILE} -bf -p ${INSTALL_DIR}
rm ${INSTALL_FILE}

# Dl certificate
mkdir -p ${PIP_CONF_DIR}
curl --silent -k https://itbox-nexus-arc.fr.world.socgen/nexus-arc/content/repositories/sgcib-itec-toolbox-maven2-hosted-releases/itec-arc/toolbox/cacerts/2.0/cacerts-2.0.crt -o ${PIP_CONF_DIR}/cacerts

# Easy-install configuration
curl --silent -k https://sgithub.fr.world.socgen/raw/CDPlatformPython/python-configuration/master/alt/conf/pydistutils.cfg -o ${CONF_DIR}/.pydistutils.cfg

# pip configuration
curl --silent -k https://sgithub.fr.world.socgen/raw/CDPlatformPython/python-configuration/master/alt/conf/pip.ini -o ${PIP_CONF_DIR}/pip.conf
sed -i "s|%CERT_DIR%|${PIP_CONF_DIR}/cacerts|g" ${PIP_CONF_DIR}/pip.conf

# conda configuration
curl --silent -k https://sgithub.fr.world.socgen/raw/CDPlatformPython/python-configuration/master/alt/conf/.condarc -o ${CONF_DIR}/.condarc
sed -i "s|%CERT_DIR%|${PIP_CONF_DIR}/cacerts|g" ${CONF_DIR}/.condarc

# Certifi installation + patch
${INSTALL_DIR}/bin/pip install certifi
cat ${PIP_CONF_DIR}/cacerts >> `${INSTALL_DIR}/bin/python -m certifi`

# Adding to PATH
echo "export PATH=${INSTALL_DIR}/bin:\${PATH}" >> ${CONF_DIR}/.bashrc
echo "Please type 'export PATH=${INSTALL_DIR}/bin:\${PATH}' to start using the new python version right away"
