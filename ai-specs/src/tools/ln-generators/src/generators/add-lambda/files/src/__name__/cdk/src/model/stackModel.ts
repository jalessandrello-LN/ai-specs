import { BaseStackConfigModel } from '@ln/aws-core-cdk-utils';

import { LambdaStackModel } from './stackConfig';

class StackElements {
  readonly LambdaFunctions: LambdaFunctions;

  constructor(data: Partial<StackElements>) {
    if (!data.LambdaFunctions)
      throw new Error('Lambda functions definition is required');

    this.LambdaFunctions = data.LambdaFunctions;
  }
}

export class LambdaFunctions {
  constructor(data: Partial<LambdaFunctions>) {}
}

export class StackModel extends BaseStackConfigModel {
  readonly StackElements: StackElements;

  constructor(data: Partial<StackModel>) {
    super(data);

    if (!data.StackElements) throw new Error('StackElements is required');

    this.StackElements = data.StackElements;
  }
}
