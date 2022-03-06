# BlazeMeter Performance Tests [![CircleCI](https://circleci.com/gh/newscorp-ghfb/wd-performance.svg?style=svg&circle-token=0c836dff7538c57fe32a6ee0b5dabd6360280639)](https://circleci.com/gh/newscorp-ghfb/wd-performance)

* [Running tests on CI](#running-tests-on-ci)
* [Running tests locally](#running-tests-locally)
   * [Requirements](#requirements)
   * [Usage](#usage)
      * [Configuration](#configuration)
* [Environments](#environments)
* [Reports](#reports)
   * [Past reports](#past-reports)
   * [Cloud Reports (Blazemeter)](#cloud-reports-blazemeter)
* [Writing tests](#writing-tests)
   * [Test executions](#test-executions)
   * [Parameters in test files](#parameters-in-test-files)
* [Bypassing Kong gateway](#bypassing-kong-gateway)

## Running tests on CI
For each test suite under `/executions`, each one can be run on [Circle CI](https://circleci.com/gh/newscorp-ghfb/workflows/wd-performance/tree/master) from the workflows page, for example:
1. Graph API Performance tests
3. talkSPORT v3 Performance tests

These can only be run from the `master` branch.

> **Please run only one suite at a time, these are not meant to run in parallel**.

## Running tests locally

Step 1: In hosts file make sure to set the tests to go to local machine (otherwise they will test the application and hence cause Alerts. For any testing on Dev, Staging and Prod - we need to inform the team):

Command to get to hosts file: `nano /etc/hosts` (you will probably need elevated access (sudo) in order to make changes)
```
 127.0.0.1 talksport.staging.apps-wireless.radio
 127.0.0.1 join.uat.wireless.radio
 127.0.0.1 api.staging-news.co.uk
 127.0.0.1 dev-public-graph.wireless-dev.newsuk.tech
```

> **_NOTE:_**  Confirm that the urls in the host file are the same as the ones from the configuration (which can be found in /scripts/run-tests) that you will use. For example if you are going to use TARGET_ENV=staging-eks make sure that you have pointed all urls from that configuration to localhost

Step 2: Start the services that you want to test with these performance tests. (for example GraphAPI+Programmes-API)

Step 3: Find your private IP inside your network (the one given by your router for example 192.168.1.8 . As this is running inside Docker the localhost won't work. On Mac, you can use `http://host.docker.internal` )

Step 4: Run the command to start the services.

For example to run the performance tests against Graph_API run:
```
export AUTH0_TOKEN="eyXXXXXXXXX_REPLACE_THIS_TOKEN_XXXXXXX"
export GRAPH_URL="http://YOUR_PRIVATE_IP_IN_STEP_3/audio/v1/graph"
export FILE_TO_EXECUTE=./tests/executions/Graph_API/low.yaml
export TARGET_ENV=staging-eks
make run-local
```

Step 5: return your hosts file back to normal when finished.


### Requirements
- Docker
- A BlazeMeter API key for the Wireless Digital workspace
- `x-access-token` for the Staging API

### Usage
Generated from `make help`:

```
run-local            	 Run test locally, runs sample test by default, e.g. FILE_TO_EXECUTE=<path to file> make run-local
run-cloud            	 Run test on Blazemeter, e.g. NAME=<test name on blazemeter> FILE_TO_EXECUTE=<path to file> make run-cloud
copy-artifacts       	 Copies test files, logs and reports to local, e.g. ARTIFACTS_PATH=./artifacts make copy-artifacts
lint                 	 Lint test scripts from entrypoint FILE_TO_EXECUTE
validate-circleci    	 Validates the circleci config at ./circleci/config.yaml e.g. TOKEN=<TOKEN> make validate-circleci
```
#### Run on Cloud
When using the `run-cloud`, you need to specify `API_TOKEN` environment variable with your own API key and secret. In Blazemeter, top right, click the _cog_ icon next to the workspace drop down.
You should get a menu on the left hand side which includes `API Keys`. Select, and generate a new key id/secret pair.

Before you run `make run-cloud` you need to provide the following environment variables:
1. `API_TOKEN` - a combination of both API key id and secret, in the format `id:secret` (remember to quote the pair to prevent the shell interpreting the values)
2. `ACCESS_TOKEN` - a JWT for access the Staging CDN (Reel)
3. `FILE_TO_EXECUTE` - the path and name of the file to run, e.g. "tests/executions/talkSPORT_App/v3/normal.execution.yaml"
4. `PROJECT_NAME` - Defaults to `talkSPORT backend`. Other values configured are `Middleware virgin-radio`.

#### Configuration

| Environment Variable | Value                                            | Description                                                                               |
|----------------------|--------------------------------------------------|-------------------------------------------------------------------------------------------|
| `ACCESS_TOKEN`       | `staging_access_token`                           | Staging CDN access token                                                                  |
| `API_TOKEN`          | `api_key_id:api_key_secret`                      | Blazemeter access token                                                                   |
| `AUTH0_TOKEN`        | `audio-platform access token`                    | Auth0 access token for audio platform tests                                               |
| `TARGET_ENV          | `[staging, staging-elb, dev]` Default: `staging` | Environment to run tests against                                                          |
| `RUN_ON`             | `[local, cloud]` Default: `local`                | Resource to provision tests on                                                            |
| `INTERACTIVE`        | `[true, false]` Default: `true`                  | Allows user input from terminal when test is running.  Set to `false` when running on CI. |

## Environments
Tests can be run against the following two environments using the `TARGET_ENV` parameter.

| TARGET_ENV  | URL                                        |
|-------------|--------------------------------------------|
| staging     | https://talksport.stage.mpp-kwatee.com     |
| staging-elb | https://talksport-elb.stage.mpp-kwatee.com |
| dev         | https://dev.graph.wireless-dev.newsuk.tech |

## Reports
### Past reports
Past reports can be found on confluence [here](https://nidigitalsolutions.jira.com/wiki/spaces/WD/pages/1349648477/Performance+Test+Reports).

### Cloud Reports (Blazemeter)
Reports can be found under the following section on the BlazeMeter website:
- Account: News UK
- Workspace: Wireless Digital
- Project: talkSPORT Backend

Reports have the following naming convention: `WD Backend Test - $TEST_NAME - $ENV`

Reports and other artifacts also get generated locally within an `/artifacts` directory. This will contain the full test config within `merged.yaml`. Circle CI does not support the mounting of volumes; instead, test artifacts are copied to and from the container. When running locally (`make run-local`), use `make copy-artifacts` to copy to local directory.

## Writing tests
Tests are using the open source [Taurus](https://gettaurus.org/docs/Index/) framework.

The easiest way to write tests is to copy an existing execution and a scenario file and modify accordingly. The test files are moderately easy to understand and have comments throughout documenting the different sections. Official documentation for writing tests can be found here:

- https://gettaurus.org/docs/ExecutionSettings/#Load-Profile
- https://gettaurus.org/docs/ExecutionSettings/#Scenario

### Generating datasources

Some tests requires data that varies between environments. You should generate those and commit them to the codebase

```bash
export GRAPH_URL="https://api.staging-news.co.uk/audio/v1/graph"
export AUTH0_TOKEN=<token>
make generate-data-sources
```

### Test executions
Each `tests/executions/../[*.]execution.yaml` file represents a test that can be executed on BlazeMeter. These files are responsible for the following:
- specifying the amount of load to generate
- specifying the duration, ramp-up and ramp-down
- specifying the scenarios to run
- specifying the engine/instances to be used to generate the tests

Scenarios are responsible for defining the behaviour of the test. It is used to control what requests are made, authentication, and can contain complex logic to simulate user journeys via our APIs. Scenarios are contained within the `/tests/scenarios` folder and can be included in execution files by including
```
included-configs:
- scenarios/some.scenarios.yaml
```

### Parameters in test files
All settings within executions, scenarios, and other YAML files, can be parametrized using the syntax `${variable-name}` and executing using `./scripts/run-tests` with `-o settings.env.variable-name="some value"`

## Bypassing Kong gateway
Most of the APIs being tested are behind auth in one way or another. The `profile-api` and `graph-api` are behind Kong gateway, which can act as a bottleneck.

If you want to bypass Kong to test the performance of the internal APIs directly, you can run using `TARGET_ENV=staging-no-kong`

You will need to ensure that the APIs are exposed publically to run the test. Use the deployment templates within `/scripts` to set up public endpoints for the APIs.
