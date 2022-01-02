resource "aws_security_group" "efs_sg" {
  name        = "${var.vpc_name}-efs-sg"
  description = "controls access to efs"

  vpc_id = aws_vpc.default.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    security_groups = [aws_security_group.eks_cluster_sg.id , aws_security_group.eks_nodes.id ]
  }

  tags =  {
      "Name" = "${var.vpc_name}-efs-sg"
    }  
  
}

resource "aws_efs_file_system" "efs" {
encrypted = true

}


resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.efs.id
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.availability_zones_without_b) # 나중에 구성시 프론트 엔드단 ,백엔드 단 2개필요
  
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(aws_subnet.private.*.id, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}
