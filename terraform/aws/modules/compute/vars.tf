# variable "vpca_id" {}
# variable "sn_vpca_pub1a" {}
# variable "sn_vpca_pub1c" {}
# variable "ec2_ami" {
#    type    = string
#    default = "ami-02e136e904f3da870"
#    validation {
#        condition = (
#            length(var.ec2_ami) > 4 &&
#            substr(var.ec2_ami, 0, 4) == "ami-"
#        )
#        error_message = "O valor da variável ec2_ami deve iniciar com \"ami-\"."
#    }
# }