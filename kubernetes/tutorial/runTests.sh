#!/bin/bash
# Copyright 2019, Oracle Corporation and/or its affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
# domain1: DomainHomeInImage
# domain2: DomainHomeInImage_ServerLogsInPV
# domain3: DomainHomeOnPV
#
# Usage:
# To run all tests from scratch: call function 'runAll'.
# If the oprator and Ingress controllers are ready (those are done in function beforeAll), 
#   to rerun all domain tests: call function 'suiteOne'.
#   to rerun some domain tests: 
#     to run seperate domain tests with WLST: call function 'testDomain1WLST', 'testDomain2WLST' and/or 'testDomain3WLST';
#     to run seperate domain tests with WDT: call function 'testDomain1WDT', 'testDomain2WDT' and/or 'testDomain3WDT'.
#

source ./waitUntil.sh
source ./setenv.sh

resultFile=results
passcnt=0
failcnt=0

domainUrlTreafik=http://$HOSTNAME:30305/weblogic/
domainUrlTreafikHttps=https://$HOSTNAME:30443/weblogic/
domainUrlVoyager=http://$HOSTNAME:30305/weblogic/

# this need to be run once before any domain test
function beforeAll() {
  ./domain.sh checkPV
  if [ $? != 0 ]; then
   exit 1
  fi
  cleanAll
  rm $resultFile
  ./operator.sh pullImages
  createOperator && createTraefik && createVoyager
  if [ $? != 0 ]; then
    echo "fail to create the operator or ingress controllers"
    exit 1
  fi

}

# this need to be run once after all tests
function afterAll() {
  printResult
}

function cleanAll() {
  cleanDomains
  ./voyager.sh delIng
  ./voyager.sh delCon

  ./traefik.sh delIng
  ./traefik.sh delCon

  ./operator.sh delete
  ./operator.sh delImages
}

# This is to be run before each domain test
function setup() {
  cleanDomains
  echo "setup begin"
  ./domain.sh checkPV
  bash -e ./domain.sh createPV
  echo "setup end"
}

function cleanDomains() {

  # clean all domains
  ./domain.sh delAll
  ./domain.sh waitUntilAllStopped

  # clean pv folder
  ./domainHomeBuilder/cleanpv/run.sh
}

#Usage: checkResult result testName
function checkResult() {
   if [ $1 = 0 ]; then
    echo "PASS: $2" >> $resultFile
    ((passcnt=passcnt+1))
  else
    echo "FAIL: $2" >> $resultFile
    ((failcnt=failcnt+1))
    failcases="$failcases $2"
  fi
}

function printResult() {
  echo |& tee -a $resultFile
  echo "###################################################"  |& tee -a $resultFile
  echo "Test restuls: "  |& tee -a  $resultFile
  echo "Passed Tests: $passcnt" |& tee -a $resultFile
  echo "Failed Tests: $failcnt"  |& tee -a $resultFile
  if [ $failcnt != 0 ]; then
    echo "Failed Cases: $failcases"  |& tee -a $resultFile
  fi
  echo "###################################################"  |& tee -a $resultFile
  echo |& tee -a $resultFile
  echo |& tee -a $resultFile
}

function createOperator() {
  echo "createOperator begin"
  ./operator.sh create
  result=$?
  checkResult $result create_Operator
  echo "createOperator end"
  return $result
}

function createTraefik() {
  echo "createTraefik begin"
  ./traefik.sh createCon && ./traefik.sh createIng
  result=$?
  checkResult $result create_Traefik
  echo "createTraefik end"
  return $result
}

function createVoyager() {
  echo "createVoyager begin"
  ./voyager.sh createCon && ./voyager.sh createIng
  result=$?
  checkResult $result create_Voyager
  echo "createVoyager end"
  return $result
}

#Usage: createDomain1 testName
function createDomain1() {
  echo "$1 begin"
  ./domain.sh createDomain1
  ./domain.sh waitUntilReady default domain1
  checkResult $? $1
  echo "$1 end"
}

#Usage: createDomain2 testName
function createDomain2() {
  echo "$1 begin"
  ./domain.sh createDomain2
  ./domain.sh waitUntilReady test1 domain2
  checkResult $? $1
  echo "$1 end"
}

#Usage: createDomain3 testName
function createDomain3() {
  echo "$1 begin"
  ./domain.sh createDomain3
  ./domain.sh waitUntilReady test1 domain3
  checkResult $? $1
  echo "$1 end"
}

function verifyTraefik() {
  echo "verifyTraefik begin"

  # verify http
  waitUntilHttpReady "domain1 via Traefik" domain1.org $domainUrlTreafik
  checkResult $? verify_Domain1_Traefik_Http
  waitUntilHttpReady "domain2 via Traefik" domain2.org $domainUrlTreafik
  checkResult $? verify_Domain2_Traefik_Http
  waitUntilHttpReady "domain3 via Traefik" domain3.org $domainUrlTreafik
  checkResult $? verify_Domain3_Traefik_Http

  # verify https
  waitUntilHttpsReady "domain1 via Traefik" domain1.org $domainUrlTreafikHttps
  checkResult $? verify_Domain1_Traefik_Https
  waitUntilHttpsReady "domain2 via Traefik" domain2.org $domainUrlTreafikHttps
  checkResult $? verify_Domain2_Traefik_Https
  waitUntilHttpsReady "domain3 via Traefik" domain3.org $domainUrlTreafikHttps
  checkResult $? verify_Domain3_Traefik_Https

  # verify traefik dashboard
  waitUntilHttpReady "traefik dashboard" traefik.example.com  http://$HOSTNAME:30305/dashboard/
  checkResult $? verify_Traefik_Dashboard

  echo "verifyTraefik end"
}

#Usage: verifyHTTP  httpCode testName
function verifyHTTPCode() {
  if [ $1 = 200 ]; then 
    checkResult 0 $2
  else
    checkResult 1 $2
  fi
}


function verifyVoyager() {
  echo "verifyVoyager begin"

  waitUntilHttpReady "domain1 via Voyager" domain1.org $domainUrlVoyager
  checkResult $? verify_Domain1_Voyager_Http
  waitUntilHttpReady "domain2 via Voyager" domain2.org $domainUrlVoyager
  checkResult $? verify_Domain2_Voyager_Http
  waitUntilHttpReady "domain3 via Voyager" domain3.org $domainUrlVoyager
  checkResult $? verify_Domain3_Voyager_Http

  # verify voyager stats 
  # TODO: not hostname
  waitUntilHttpReady "voyager stats" domain1.org http://$HOSTNAME:30317

  echo "verifyVoyager end"
}

function verifyLB() {
  verifyTraefik
  verifyVoyager  
}

# usage: verfiyLBForDomain domainName
function verfiyLBForDomain() {
   # verify via Traefik
  waitUntilHttpReady "$1 via Traefik" $1.org $domainUrlTreafik
  checkResult $? verify_$1_Traefik_Http
  waitUntilHttpsReady "$1 via Traefik" $1.org $domainUrlTreafikHttps
  checkResult $? verify_$1_Traefik_Https

  # verify via Voyager
  waitUntilHttpReady "domain1 via Voyager" $1.org $domainUrlVoyager
  checkResult $? verify_$1_Voyager_Http
}

function testDomain1WLST() {
  export DOMAIN_BUILD_TYPE=wlst
  createDomain1 create_Domain1_WLST
  verfiyLBForDomain domain1
}

function testDomain2WLST() {
  export DOMAIN_BUILD_TYPE=wlst
  createDomain2 create_Domain2_WLST
  verfiyLBForDomain domain2
}

function testDomain3WLST() {
  export DOMAIN_BUILD_TYPE=wlst
  createDomain3 create_Domain3_WLST
  verfiyLBForDomain domain3
}

function testDomain1WDT() {
  export DOMAIN_BUILD_TYPE=wdt
  createDomain1 create_Domain1_WDT
  verfiyLBForDomain domain1
}

function testDomain2WDT() {
  export DOMAIN_BUILD_TYPE=wdt
  createDomain2 create_Domain2_WDT
  verfiyLBForDomain domain2
}

function testDomain3WDT() {
  export DOMAIN_BUILD_TYPE=wdt
  createDomain3 create_Domain3_WDT
  verfiyLBForDomain domain3
}


function testWLST() {
  export DOMAIN_BUILD_TYPE=wlst
  createDomain1 create_Domain1_WLST
  createDomain2 create_Domain2_WLST
  createDomain3 create_Domain3_WLST

  verifyLB
}

function testWDT() {
  export DOMAIN_BUILD_TYPE=wdt
  createDomain1 create_Domain1_WDT
  createDomain2 create_Domain2_WDT
  createDomain3 create_Domain3_WDT

  verifyLB
}

# usage: traceOne testName
function traceOne() {
  SECONDS=0
  setup
  $1
  echo "$0 took $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds to finish $1."   
}

# This suite contains all the tests. It's suitable for daily-run.
function suiteOne() {
  traceOne testWLST
  traceOne testWDT
}

# This suite can run tests of seperate domains with WLST.
function suiteTwo() {
  traceOne testDomain1WLST
  traceOne testDomain2WLST
  traceOne testDomain3WLST
}

# This suite can run tests of seperate domains with WDT.
function suiteThree() {
  traceOne testDomain1WDT
  traceOne testDomain2WDT
  traceOne testDomain3WDT
}

function runAll() {
  beforeAll
  suiteOne
  afterAll
}

function runOne() {
  beforeAll
  traceOne testDomain1WLST
  afterAll
}

runOne
#runAll



