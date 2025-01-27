namespace: io.cloudslang.demo.aos.sub_flows
flow:
  name: deploy_wars
  inputs:
    - tomcat_host
    - account_service_host:
        required: true
    - db_host:
        required: true
    - username
    - password
    - url: "${get_sp('war_repo_root_url')}"
  workflow:
    - deploy_account_service:
        do:
          io.cloudslang.demo.aos.sub_flows.initialize_artifact:
            - host: '${account_service_host}'
            - username: '${username}'
            - password: '${password}'
            - artifact_url: "${url+'/accountservice.war'}"
            - script_url: "${get_sp('script_deploy_war')}"
            - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host+'accountservice'}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: deploy_tm_wars
    - deploy_tm_wars:
        loop:
          for: "war in 'catalog','mastercredit','order','shipex','safepay','ROOT'"
          do:
            io.cloudslang.demo.aos.sub_flows.initialize_artifact:
              - host: '${tomcat_host}'
              - username: '${username}'
              - password: '${password}'
              - artifact_url: "${url+'/'+war+'.war'}"
              - script_url: "${get_sp('script_deploy_war')}"
              - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host+' '+war}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      deploy_account_service:
        x: 40
        'y': 120
      deploy_tm_wars:
        x: 200
        'y': 120
        navigate:
          0cea8b1f-bfeb-3dd9-94f4-c938b314ab15:
            targetId: ba3e8e8a-ed7d-90af-1b65-c7f0dd4421c0
            port: SUCCESS
    results:
      SUCCESS:
        ba3e8e8a-ed7d-90af-1b65-c7f0dd4421c0:
          x: 400
          'y': 120
