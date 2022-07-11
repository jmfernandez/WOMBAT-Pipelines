process POLYSTEST {
  label 'process_high'

  conda (params.enable_conda ? "bioconda::polystest-1.1" : null)
  if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://quay.io/biocontainers/polystest:1.1--hdfd78af_2"
  } else {
        container "quay.io/biocontainers/polystest:1.1--hdfd78af_2"
  }
  
  publishDir "${params.outdir}/polystest", mode:'copy'
  
  when:
  params.run_statistics

  input:
  path exp_design
  path proline_res
  
  output:
  path "polystest_prot_res.csv", emit: polystest_prot
  path "polystest_pep_res.csv", emit: polystest_pep
  
  script:
  """
  convertProline=\$(which runPolySTestCLI.R)
  
  echo \$convertProline
  convertProline=\$(dirname \$convertProline)
  
  echo \$convertProline
  Rscript \${convertProline}/convertFromProline.R ${exp_design} ${proline_res}
  
  sed -i "s/threads: 2/threads: ${task.cpus}/g" pep_param.yml
  sed -i "s/threads: 2/threads: ${task.cpus}/g" prot_param.yml
  
  runPolySTestCLI.R pep_param.yml
  runPolySTestCLI.R prot_param.yml
  """

}