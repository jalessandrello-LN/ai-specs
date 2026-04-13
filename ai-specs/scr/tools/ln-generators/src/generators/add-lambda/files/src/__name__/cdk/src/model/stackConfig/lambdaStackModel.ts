export class LambdaStackModel {
  readonly Name: string;
  readonly MemorySize: number;
  readonly Path: string;
  readonly Namespace: string;

  constructor(data: Partial<LambdaStackModel>) {
    if (!data.Name) throw new Error('Lambda functions Name is required');
    this.Name = data.Name;

    this.MemorySize = data.MemorySize || 128;
    this.Path = data.Path || '';
    this.Namespace = data.Namespace || '';
  }
}
