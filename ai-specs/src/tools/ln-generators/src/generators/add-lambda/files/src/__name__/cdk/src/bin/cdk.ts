#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { createStack } from '@ln/aws-core-cdk-utils';
import { CdkStack } from '../lib/cdk-stack';
import { StackModel } from '../model/stackModel';

createStack<StackModel, CdkStack>({
  app: new cdk.App(),
  stackClass: CdkStack,
  stackConfigClass: StackModel,
});
