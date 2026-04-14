import { BundlingOutput, Duration } from 'aws-cdk-lib';
import {
  Code,
  Function as lambdaFunction,
  Runtime,
} from 'aws-cdk-lib/aws-lambda';
import { getNameOfResource, AwsComponents } from '@ln/aws-core-cdk-utils';
import { StackModel } from '../../model/stackModel';
import { Construct } from 'constructs';
import { RetentionDays } from 'aws-cdk-lib/aws-logs';
import * as path from 'path';

export class LambdaFunctions {
  public readonly functions: Record<string, lambdaFunction> = {};
  private readonly app: Construct;

  constructor(app: Construct, stackConfig: StackModel) {
    this.app = app;

    Object.entries(stackConfig.StackElements.LambdaFunctions).forEach(
      ([key, config]) => {
        const fn = this.createLambda(
          stackConfig,
          config.Name,
          config.MemorySize,
          config.Path,
          config.Namespace
        );
        this.functions[key] = fn;
      }
    );
  }

  private createLambda(
    stackConfig: StackModel,
    name: string,
    memorySize: number,
    pathLambda: string,
    namespace: string
  ): lambdaFunction {
    const functionName = getNameOfResource({
      resource: AwsComponents.LAMBDA,
      stackConfig,
      name,
    });

    console.log(
      `Namespaces: ${namespace}::${namespace}.Function::FunctionHandler`
    );

    return new lambdaFunction(this.app, functionName, {
      functionName,
      runtime: Runtime.DOTNET_8,
      handler: `${namespace}::${namespace}.Function::FunctionHandler`,
      memorySize,
      code: Code.fromAsset(
        path.resolve(stackConfig.DistDir, pathLambda, 'function.zip') // p.ej. build/apps/ExampleLambda/Invoker.Lambda
      ),
      timeout: Duration.minutes(15),
      logRetention: RetentionDays.THREE_DAYS,
    });
  }
}
