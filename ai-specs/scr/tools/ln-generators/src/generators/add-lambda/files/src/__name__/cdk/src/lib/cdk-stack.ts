import { StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { StackModel } from '../model/stackModel';
import { LambdaFunctions as lambdaResource } from './resources/lambdaFunctions';
import { BaseStack } from '@ln/aws-core-cdk-utils';

export class CdkStack extends BaseStack {
  constructor(
    scope: Construct,
    id: string,
    props: StackProps,
    stackConfig: StackModel
  ) {
    super(scope, id, props, stackConfig);

    const lambdaFunctions = new lambdaResource(this, stackConfig);

    // Usar una lambda específica si conocés el nombre lógico (ej: definido en appSettings)
    // const myLambda = lambdaFunctions['PreventaEventProducer'];

    // Agregar permisos, variables, triggers, etc.
    // myLambda.addEnvironment('TABLE_NAME', 'my-dynamo-table');
    // bucket.grantReadWrite(myLambda);
  }
}
