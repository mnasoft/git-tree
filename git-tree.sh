#!/bin/bash


USAGE="
Usage: $(basename $0) COMMAND REPO [BRANCH]

Command:
             pull      - получение изменений с сервера;
             push      - отправка изменений на сервер;
             pull_push - получение и отправка изменений;
             add       - добавление изменений;
             commit    - фиксация изменений;
             all       - получение изменений с сервера, добавление изменений,
                         фиксация изменений, отправка изменений на сервер;
"

func_usage_show ()
{
    echo  "${USAGE}"
}

func_git_push ()
{
    git push ${REPO} ${DO_BRANCH}
    echo `pwd` ${DO_BRANCH}
}

func_git_pull ()
{
    git pull ${REPO} ${DO_BRANCH}
    echo `pwd` ${DO_BRANCH}
}

func_git_add ()
{
    git add `find . -name "*.lisp" -o -name "*.org" -o -name "*.scr" -o -name "*.asd"`
}

func_git_commit ()
{
    git commit -a -m "`date -u`"
}

func_git_push_or_pull ()
{
    echo "git ${COMMAND} ${REPO} ${DO_BRANCH}"
    git ${COMMAND} ${REPO} ${DO_BRANCH}
    echo `pwd` ${DO_BRANCH}
}

func_git_command_branch ()
{
    CURRENT_BRANCH=`git branch --no-color | grep \*  | cut -d ' ' -f 2`
    if ! [[ -z "${BRANCH}" ]]
    then
        DO_BRANCH="${BRANCH}"
    else
        DO_BRANCH="${CURRENT_BRANCH}"
    fi
    
    if [[ ${COMMAND} == "push" || ${COMMAND} == "pull" ]]
    then
        func_git_push_or_pull
    fi
    
    if [[ ${COMMAND} == "pull_push" ]]
    then
        git pull ${REPO} ${DO_BRANCH}
        git push ${REPO} ${DO_BRANCH}
    fi
    
    if [[ ${COMMAND} == "add" ]]
    then
        func_git_add
    fi
    
    if [[ ${COMMAND} == "commit" ]]
    then
        func_git_commit
    fi
    
    if [[ ${COMMAND} == "all" ]]
    then
        func_git_pull
        func_git_add
        func_git_commit
        func_git_push
    fi
}

func_git_command ()
{
    CDIR=`pwd`
    for i in `find . -name ".git"`
    do
        echo "================================="
        cd ${CDIR}/${i}/../
        echo "`pwd`"
        echo "---------------------------------"
        func_git_command_branch
        echo "+++++++++++++++++++++++++++++++++"
    done
    cd ${CDIR}
}

if ! [[ -z "$3" ]]
then
    BRANCH=$3
    echo ${BRANCH}
fi

if [ -z "$2" ]
then
    func_usage_show
else
    REPO=$2
    COMMAND=$1
    if [[ ${COMMAND} == "push" || ${COMMAND} == "pull" || ${COMMAND} == "pull_push" || ${COMMAND} == "add" || ${COMMAND} == "commit" || ${COMMAND} == "all" ]]
    then
        func_git_command
    else
        echo "Unknown command: ${COMMAND}"
        func_usage_show
    fi
    
fi
