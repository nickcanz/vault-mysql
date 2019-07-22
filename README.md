# vault + mysql demo 

I was interested in using the [Hashicorp Vault](https://github.com/hashicorp/vault) database integration and wanted to put together an "end-to-end" example so that I could better understand it.

To run this example:

```

# Starts up a vault server on localhost:8200 and two different mysql servers on localhost:43306 and localhost:53306
docker-compose up -d

# Runs the appropriate API calls to set up configurations and generates users/passwords for the two different mysql servers
bash setup-steps.sh
```
