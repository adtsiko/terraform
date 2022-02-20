
variable "server_port" {
    description = "Port for HTTP requests"
    type = number
    default = 8080
}

variable "cluster_name" {
    description = "The name to use for all the cluster resources"
    type = string
}

variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for the database remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database remote state in the s3"
    type = string

}

variable "instance_type" {
    description = "EC2 instance to run"
    type = string
}

variable "min_size" {
    description = "Minimum ec2 instances"
    type = number
}

variable "max_size" {
    description = "Maximum ec2 instances"
    type = number
}

