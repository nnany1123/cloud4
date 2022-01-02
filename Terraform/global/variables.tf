variable "domain_name" {
    type = string
    description = "The domain name for the website"
}

variable "bucket_name" {
    type = string
    description = "The name of the bucket without the devs3. prefix. Normally domain_name."
}
variable "common_tags" {
    description = "common tags you want applied to all components"
  
}

variable "upload_directory" {
  default = "web/"
}

variable "mime_types" {
  default = {
    htm   = "text/html"
    html  = "text/html"
    css   = "text/css"
    ttf   = "font/ttf"
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
  }
}