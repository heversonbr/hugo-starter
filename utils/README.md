# My HomePage using Hugo

## Useful information

The current directory contains the content of the web site and is using the Hugo's theme called _minimal_.



### Folders 

- **content**: contains the website markdown content. 
- **public**: contains the current build of the website. 


### Scripts

- **start_local_server.sh**: used to start the hugo server in local dev mode.
- **update_content_to_nginx_folder.sh**: used to transfer the content in $SOURCE_CONTENT_PATH to the root directory of nginx (i.e., $DESTINATION_NGINX_ROOT).
- **build_site.sh**: used to build the site's content. The output is in the _public_ folder. 
