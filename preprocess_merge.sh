
#!/usr/bin/env bash

# ================ input arguments =========================
data_root=$1
lang=$2
eval=$3
# ================ default arguments =======================
ltf_source=${data_root}/ltf
rsd_source=${data_root}/rsd
ltf_file_list=${data_root}/ltf_lst
rsd_file_list=${data_root}/rsd_lst
# bio
edl_output_dir=${data_root}/edl
edl_bio=${edl_output_dir}/${lang}.bio
# corenlp
core_nlp_output_path=${data_root}/corenlp
# udp
udp_dir=${data_root}/udp
chunk_file=${edl_output_dir}/chunk.txt

# ================ script =========================
# generate files for full_dir
# # generate *.bio
docker run --rm -v ${data_root}:${data_root} -w `pwd` -i limanling/uiuc_ie_${eval} \
    /opt/conda/envs/py36/bin/python \
    /aida_utilities/ltf2bio.py ${ltf_source} ${edl_bio}
# # generate file list
docker run --rm -v ${data_root}:${data_root} -w `pwd` -i limanling/uiuc_ie_${eval} \
    /opt/conda/envs/py36/bin/python \
    /aida_utilities/dir_ls.py ${ltf_source} ${ltf_file_list}
# apply universal dependency parser
docker run --rm -v ${data_root}:${data_root} -i limanling/uiuc_ie_${eval} \
    mkdir -p ${udp_dir}
docker run --rm -v ${data_root}:${data_root} -w /scr -i dylandilu/chuck_coreference \
    python ./bio2udp.py \
    --lang ${lang} \
    --path_bio ${edl_bio} \
    --udp_dir ${udp_dir}
echo "finish universal dependency parser for "${rsd_source}
# chunk extraction
docker run --rm -v ${data_root}:${data_root} -w /scr -i dylandilu/chuck_coreference \
    python ./chunk_mine.py \
    --udp_dir ${udp_dir} \
    --text_dir ${rsd_source} \
    --path_out_chunk ${chunk_file}
echo "finish chunking for "${rsd_source}