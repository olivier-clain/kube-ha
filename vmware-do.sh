
#!/bin/bash
#
# Clone from Template
clear
ACTION=$1
KLONNAME=$2
IP=$3

VMDIR="/Users/narayann/OneDrive/VMware_VMs"


create(){

    # Default VM to clone
    VM="$VMDIR/template_centos7.vmwarevm/template_centos7.vmx"

    if [ -z $KLONNAME ] || [ -z $IP ];then

      echo "Give a name & an IP to the New VM"
      echo
      echo "Example: $0 hostname-1 192.168.60.XXX"
      exit 0

    fi

    if [ -d ${VMDIR}/${KLONNAME}.vmwarevm ];then
      echo "Delete existing VM !"
      delete
      #rm -Rf ${VMDIR}/${KLONNAME}.vmwarevm
    fi

    mkdir "$VMDIR/$KLONNAME.vmwarevm"
    echo
    echo "Create Dir $VMDIR/$KLONNAME.vmwarevm ..."
    echo "Cloning VM ..."
    vmrun -T fusion clone "$VM" "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx" full -cloneName=$KLONNAME

    if [ $? -eq 0 ]; then
      echo "VM cloned."
      echo "VM is going to start now !"
      vmrun -T fusion start "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx"

      echo "start ansible script"
      cd script
      ansible-playbook configure_clone.yml --extra-vars "IPADDR=$IP HOSTNAME=$KLONNAME"
      cd ..

      stop
      start

    else
      echo "Error cloning the VM. Exiting..."
      exit 1
    fi
}

suspend(){

    echo "VM $KLONNAME is going to be suspend now !"
    echo
    vmrun -T fusion suspend "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx"

}

list(){

    echo "List of running VM(s) :"
    echo "---------------------"
    vmrun -T fusion list | while read line;do
        awk -F[/.] '{print $8}' <<< $line
    done

}


listall(){

    echo "List of existing VM(s) :"
    echo "---------------------"
    echo
    ls -1 $VMDIR | cut -d. -f1
}

stop(){
    echo "VM $KLONNAME is going to be stop now !"
    echo
    vmrun -T fusion stop "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx"

}

start(){

    if [ "$IP" = "--with_gui" ];then
      echo "VM $KLONNAME is going to be start now with gui !"
      echo
      vmrun -T fusion start "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx"
    else
      echo "VM $KLONNAME is going to be start now !"
      echo
      vmrun -T fusion start "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx" nogui
    fi

}

delete(){

    list > .list

    grep $KLONNAME .list 1> /dev/null

    if [ $? -eq 0 ];then
      stop
    fi

    echo "VM $KLONNAME is going to be remove now !"
    echo

    vmrun -T fusion deleteVM "$VMDIR/$KLONNAME.vmwarevm/$KLONNAME.vmx"
    rm -Rf $VMDIR/$KLONNAME.vmwarevm
}


if [ -z $ACTION ]; then
  echo
  echo "$0 [delete|start|create|stop|suspend|list] vm_name (optional: --with_gui or IP: 192.168.60.XXX)"
  echo
  exit 1
else
  case $ACTION in
    delete)
      delete;;
    start)
      start;;
    create)
      create;;
    stop)
      stop;;
    list)
      list;;
    suspend)
      suspend;;
    listall)
      listall;;
    *)
      echo
      echo "$0 [delete|start|create|stop|suspend|list|listall] vm_name (optional: --with_gui or IP: 192.168.60.XXX)"
      echo
      ;;
  esac

fi


exit 0
