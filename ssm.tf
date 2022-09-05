# Document
resource "aws_ssm_document" "web" {
  name          = "web"
  document_type = "Command"
  content       = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Ansible Playbooks via SSM",
    "parameters": {
    "SourceType": {
      "description": "(Optional) Specify the source type.",
      "type": "String",
      "allowedValues": [
      "GitHub",
      "S3"
      ]
    },
    "SourceInfo": {
      "description": "Specify 'path'. Important: If you specify S3, then the IAM instance profile on your managed instances must be configured with read access to Amazon S3.",
      "type": "StringMap",
      "displayType": "textarea",
      "default": {}
    },
    "PlaybookFile": {
      "type": "String",
      "description": "(Optional) The Playbook file to run (including relative path). If the main Playbook file is located in the ./automation directory, then specify automation/playbook.yml.",
      "default": "hello-world-playbook.yml",
      "allowedPattern": "[(a-z_A-Z0-9\\-)/]+(.yml|.yaml)$"
    },
    "ExtraVariables": {
      "type": "String",
      "description": "(Optional) Additional variables to pass to Ansible at runtime. Enter key/value pairs separated by a space. For example: color=red flavor=cherry",
      "default": "",
      "displayType": "textarea"
    },
    "Verbose": {
      "type": "String",
      "description": "(Optional) Set the verbosity level for logging Playbook executions. Specify -v for low verbosity, -vv or vvv for medium verbosity, and -vvvv for debug level.",
      "allowedValues": [
      "-v",
      "-vv",
      "-vvv",
      "-vvvv"
      ],
      "default": "-v"
    }
    },
    "mainSteps": [
    {
      "action": "aws:downloadContent",
      "name": "downloadContent",
      "inputs": {
      "SourceType": "{{ SourceType }}",
      "SourceInfo": "{{ SourceInfo }}"
      }
    },
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
      "runCommand": [
        "#!/bin/bash",
        "apt-get update",
        "DEBIAN_FRONTEND=noninteractive apt-get -y install python3-pip",
        "# install ansible",
        "pip3 install --user ansible",
        "echo \"Running Ansible in `pwd`\"",
        "for zip in $(find -iname '*.zip'); do",
        "  unzip -o $zip",
        "done",
        "PlaybookFile=\"{{PlaybookFile}}\"",
        "if [ ! -f  \"$${PlaybookFile}\" ] ; then",
        "   echo \"The specified Playbook file doesn't exist in the downloaded bundle. Please review the relative path and file name.\" >&2",
        "   exit 2",
        "fi",
        "~/.local/bin/ansible-playbook -i \"localhost,\" -c local -e \"{{ExtraVariables}}\" \"{{Verbose}}\" \"$${PlaybookFile}\""
      ]
      }
    }
    ]
  }
DOC
}

## association (playbook)
# master
resource "aws_ssm_association" "web" {
  association_name = "web"
  name             = aws_ssm_document.web.name
  targets {
    key    = "tag:Name"
    values = ["http_server_1","http_server_2"]
  }
  output_location {
    s3_bucket_name = aws_s3_bucket.bucket.id
    s3_key_prefix  = "logs"
  }
  parameters = {
    ExtraVariables = ""
    PlaybookFile   = "playbook.yaml"
    SourceInfo     = "{\"path\":\"https://s3.${aws_s3_bucket.bucket.region}.amazonaws.com/${aws_s3_bucket.bucket.id}/playbook/\"}"
    SourceType     = "S3"
    Verbose        = "-vvv"
  }
}
