# Setup a infoblox server in AWS for dev



Based on the following module:
[https://github.com/tylerhatton/infoblox-tf-templatei](https://github.com/tylerhatton/infoblox-tf-template)


## USE
Add a file, keypair.tf with the following:
```
resource "aws_key_pair" "something" {
  key_name   = "something-something"
  public_key = "ssh-rsa AAABBBCCC your_key"
}
```
* the ssh key required for an AWS instance
* file is already ignored my .gitignore

Should work with a standard AWS terraform config


