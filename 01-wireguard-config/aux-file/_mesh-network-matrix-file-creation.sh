
#!/bin/bash
. config 

#$1 - MATRIX


if [ "$#" -lt 1 ]
then
  echo "Usage: $0 <comma-separated-mesh-network-matrix>"
  exit
fi

echo $1
exit
NODE_NUMBER=3

FILE_NAME_INDEX=$(echo ${MESH_NETWORK_MATRIX_FILE} | tr '/' ' ' | wc -w)
FILE_NAME=$(echo  ${MESH_NETWORK_MATRIX_FILE} | cut -f $(( ${FILE_NAME_INDEX}+1 )) -d '/' )
DIRECTORY_NAME=$(echo  ${MESH_NETWORK_MATRIX_FILE} | cut -f 1-$(( ${FILE_NAME_INDEX} )) -d '/' )

echo file_name: ${FILE_NAME}
echo direct_name: ${DIRECTORY_NAME}
[ -e  ${DIRECTORY_NAME}/${FILE_NAME} ] && rm  ${DIRECTORY_NAME}/${FILE_NAME}
for ((j=1;j<=${NODE_NUMBER};j++)) do
    row=
    for ((i=1;i<=${NODE_NUMBER};i++)) do
         #row=$(echo ${MESH_NETWORK_MATRIX[$i,$j]},${row})
         row=$(echo ${1[$i,$j]},${row})
    done
    (echo ${row} | sed 's/,$//') >> ${DIRECTORY_NAME}/${FILE_NAME}
done










