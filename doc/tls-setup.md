# TLS Set-up on YottaDB and Caché
Setting up TLS is usually hard. These instructions are provided in the hope that they 
can guide you, but there is not guarantee that they will work. Comments inline.
## YottaDB (& GT.M)
```
# Compile the plugin
apt-get install libgcrypt11-dev libgpgme11-dev libconfig-dev libssl-dev
cd $ydb_dist/plugin/gtmcrypt
tar x < source.tar
ydb_dist=../.. make
ydb_dist=../.. make install

# Go to your database
cd /data

# Create your certificate with a key that has a password. I know from previous
# interaction with the GT.M developers is that they don't allow passwordless keys
# for business reasons. Here's is how I did it; but you may already have a
# certificate. I moved all the files into a cert directory after this.
openssl genrsa -aes128 -passout pass:monkey1234 -out ./mycert.key 2048
openssl req -new -key ./mycert.key -passin pass:monkey1234 -subj '/C=US/ST=Washington/L=Seattle/CN=www.smh101.com' -out ./mycert.csr
openssl req -x509 -days 365 -sha256 -in ./mycert.csr -key .//mycert.key -passin pass:monkey1234 -out ./mycert.pem
mkdir certs
mv mycert.* certs/

# Create a file (name doesn't matter) called gtmcrypt_config.libconfig with the
# following contents. Note the section called dev. This can be called anything.
# It lets you put a pair of cert/key for each environment you need to configure.
cat gtmcrypt_config.libconfig
tls: {
  dev: {
    format: "PEM";
    cert: "/data/certs/mycert.pem";
    key:  "/data/certs/mycert.key";
  }
}

# In your file that sets up the GT.M environment, add set the env variable
# gtmcrypt_config to be the path to your config file:
export ydbcrypt_config="/data/gtmcrypt_config.libconfig"

# Find out the hash of your key password using the maskpass utility
$ydb_dist/plugin/gtmcrypt/maskpass <<< 'monkey1234' | cut -d ":" -f2 | tr -d ' '

# In your environment file, gtmtls_passwd_{section name} to be that hash. For me, it's:
export ydbtls_passwd_dev="30A22B54B46618B4361F"

# Run the server like this, substituting the {section name} appropriately. here it is dev
$ydb_dist/mumps -r %XCMD 'do job^%webreq(9080,"dev")'

# Test the server like this
curl -k https://localhost:9080
```

## Caché
Configure an SSL/TLS Configuration as [described
here](https://cedocs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=GCAS_ssltls#GCAS_ssltls_createedit).

The server should be started like this: `do job^%webreq(9080,"configuration_name")`.
