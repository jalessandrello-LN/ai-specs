using Amazon.Lambda.Core;
// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace <%= namespace %>;

public class Function
{
    /// <summary>
    /// Handler principal. Modificá el tipo de `input` según el evento que recibe tu lambda.
    /// </summary>
    public object FunctionHandler(object input, ILambdaContext context)
    {
        Console.WriteLine("🔧 Lambda ejecutada con input:");
        Console.WriteLine(input);

        return new { status = "ok" };
    }

    /*
    🧬 EJEMPLOS DE INPUT SEGÚN EVENTO

    // 📌 1. Si recibís un CloudWatch Event:
    using Amazon.Lambda.CloudWatchEvents;
    public Task FunctionHandler(CloudWatchEvent<object> input, ILambdaContext context)

    // 📌 2. Si recibís eventos desde SQS:
    using Amazon.Lambda.SQSEvents;
    public Task FunctionHandler(SQSEvent input, ILambdaContext context)

    // 📌 3. Si recibís cambios desde un stream de DynamoDB:
    using Amazon.Lambda.DynamoDBEvents;
    public Task FunctionHandler(DynamoDBEvent input, ILambdaContext context)

    // 📌 4. Si recibís objetos JSON planos (ejemplo: API Gateway con proxy desactivado):
    public Task FunctionHandler(MyCustomInput input, ILambdaContext context)

    // 📌 5. Si recibís eventos de S3 (ej. al subir archivos):
    using Amazon.Lambda.S3Events;
    public Task FunctionHandler(S3Event input, ILambdaContext context)
    */
}
