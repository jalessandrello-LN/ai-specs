using Amazon.Lambda.SQSEvents;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.TestUtilities;
using Amazon.StepFunctions;
using Amazon;
using Amazon.Runtime;
using System.Text.Json;
using Amazon.Runtime.CredentialManagement;
using System.Diagnostics;
using <%= name %>;

class Program
{
    static async Task Main(string[] args)
    {
        var context = new TestLambdaContext();

        // 📦 Leer variables de entorno
        var useLocalstack = Environment.GetEnvironmentVariable("USE_LOCALSTACK") == "true";
        var region = RegionEndpoint.USEast1;

        IAmazonStepFunctions client;

        if (useLocalstack)
        {
            client = new AmazonStepFunctionsClient(
                new EnvironmentVariablesAWSCredentials(),
                new AmazonStepFunctionsConfig
                {
                    ServiceURL = "http://localhost:4566",
                    AuthenticationRegion = "us-east-1"
                }
            );
            Console.WriteLine("🧪 Usando LocalStack");
        }
        else
        {
            var profileName = Environment.GetEnvironmentVariable("AWS_PROFILE") ?? "default";
            var sharedFile = new SharedCredentialsFile();

            if (!sharedFile.TryGetProfile(profileName, out var profile))
                throw new Exception($"❌ No se encontró el perfil AWS '{profileName}'");

            if (!AWSCredentialsFactory.TryGetAWSCredentials(profile, sharedFile, out var credentials))
                throw new Exception($"❌ No se pudieron obtener las credenciales del perfil '{profileName}'");

            var ssoCredentials = credentials as SSOAWSCredentials;

            ssoCredentials.Options.ClientName = "Client-Lambda-SSO";
            ssoCredentials.Options.SsoVerificationCallback = args =>
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = args.VerificationUriComplete,
                    UseShellExecute = true
                });
            };

            client = new AmazonStepFunctionsClient(ssoCredentials, region);
            Console.WriteLine($"🔐 Usando perfil AWS con soporte SSO: {profileName}");
        }


        //var function = new Function(stepFunctionArn, client);

        // var result = await function.FunctionHandler(request, context);
        // Console.WriteLine($"✅ Resultado Step Function Simple: {result.Body}");

    }
}
