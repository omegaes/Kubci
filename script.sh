#!/bin/bash

NEW_TAG=$1

cloneAndChangeDirectoryToEnvRepo(){
    REPO_FOLDER_NAME="$(basename "$ENV_REPO_URL" .git)"
    rm -rf  $REPO_FOLDER_NAME
    git clone $ENV_REPO_URL
    cd $REPO_FOLDER_NAME
}

configureGit() {
    git config  --global credential.helper store
    git config credential.helper cache
    git config --global user.email $GIT_USER_EMAIL
    git config --global user.name $GIT_USER_NAME
}

checkoutFromTargetBranch(){
    git checkout $ENV_REPO_TARGET_BRANCH
}

createMergeBranch(){
    git checkout -b $ENV_REPO_MERGE_BRANCH
}


updateRelatedKubeFiles(){
    IFS=';' read -r -a files <<< "$ENV_REPO_FILES"
    for file in "${files[@]}"; do
        yq w -i $file "images[0].newTag" $NEW_TAG
    done
}

commitAndPushNewChanges(){
    git add .
    git commit -m "New build on repo $REPO_NAME:$BRANCH_NAME:$NEW_TAG"
    git push --set-upstream --force origin $ENV_REPO_MERGE_BRANCH
    git checkout $ENV_REPO_TARGET_BRANCH
    git pull origin $ENV_REPO_TARGET_BRANCH
    git merge $ENV_REPO_MERGE_BRANCH
    git push origin $ENV_REPO_TARGET_BRANCH
}


main(){
    cloneAndChangeDirectoryToEnvRepo
    configureGit
    checkoutFromTargetBranch
    createMergeBranch
    updateRelatedKubeFiles
    commitAndPushNewChanges
}

main