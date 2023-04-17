case $# in
  0)  echo "use: $(basename $0) gar_archive" 1>&2
      exit 1
      ;;
  1)  p_gar="$1"
      gasadmin gar --disable-archive $p_gar
      gasadmin gar --undeploy-archive $p_gar
      gasadmin gar --deploy-archive $p_gar
      gasadmin gar --enable-archive $p_gar
esac
