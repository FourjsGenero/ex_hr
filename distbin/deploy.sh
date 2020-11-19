case $# in
  1)  p_gar="$1"
      gasadmin gar --disable-archive $p_gar
      gasadmin gar --undeploy-archive $p_gar
      gasadmin gar --deploy-archive $p_gar
      gasadmin gar --enable-archive $p_gar
esac
