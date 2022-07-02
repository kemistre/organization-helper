#!/bin/bash

echo "Executing list repositories details script"
jq --version


# organization="$1"
# github_token="$2"
# organization=kemistre
github_api_url='https://api.github.com'



START=1
total_pages=1

echo repository, html_url, api_url, created_at, pushed_at, advanced_security, secret_scanning, secret_scanning_push_protection > oraganization_repository_details.csv

for (( c=$START; c<=$total_pages; c++ ))
do
	echo "=============Navigating Page number: $c============="
	echo "=============Listing repos in organization: '${ORG_NAME}'=============" 
	list_repos_url="${github_api_url}/orgs/${ORG_NAME}/repos?per_page=10&page=${c}"
	echo "List Repo URL: $list_repos_url"
    all_repo_list=$(curl --location --request GET -H 'Accept: application/vnd.github.+json' -H "Authorization: token $LOCAL_GITHUB_TOKEN" $list_repos_url)
	echo "${all_repo_list}" | jq -c ".[]" | while read repo;do
		repo_name=$(echo $repo | jq '.name' | tr -d '"')
		html_url=$(echo $repo | jq '.html_url' | tr -d '"')
		api_url=$(echo $repo | jq '.url' | tr -d '"')
		created_at=$(echo $repo | jq '.created_at' | tr -d '"')
		pushed_at=$(echo $repo | jq '.pushed_at' | tr -d '"')
		# echo "${repo_name}, ${api_url}"
        repo_details=$(curl --location --request GET -H 'Accept: application/vnd.github.+json' -H "Authorization: token $LOCAL_GITHUB_TOKEN" $api_url)
        advanced_security=$(echo $repo_details | jq '.security_and_analysis.advanced_security.status' | tr -d '"')
        secret_scanning=$(echo $repo_details | jq '.security_and_analysis.secret_scanning.status' | tr -d '"')
        secret_scanning_push_protection=$(echo $repo_details | jq '.security_and_analysis.secret_scanning_push_protection.status' | tr -d '"')

		echo "${repo_name}, ${html_url}, ${api_url}, ${created_at}, ${pushed_at}, ${advanced_security}, ${secret_scanning}, ${secret_scanning_push_protection}" >> oraganization_repository_details.csv
	done
done
