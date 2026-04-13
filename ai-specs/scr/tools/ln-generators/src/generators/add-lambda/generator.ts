import {
  Tree,
  formatFiles,
  generateFiles,
  joinPathFragments,
  names,
} from '@nx/devkit';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { globSync } from 'glob';

interface Options {
  name: string;
  namespace: string;
  memorySize: number;
  cdkOption: number;
  cdkName: string;
}

/**
 * Normaliza el nombre ingresado para obtener variantes útiles para los archivos y namespaces.
 * - Convierte a PascalCase.
 * - Deriva el nombre final, nombre de clase, nombre de archivo, namespace y clave de lambda.
 */
function normalizeName(raw: string) {
  const hasLambdaSuffix = raw.toLowerCase().endsWith('.lambda');
  const base = hasLambdaSuffix ? raw.slice(0, -7) : raw;
  const formattedBase = base
    .split('.')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('.');
  const finalName = `${formattedBase}.Lambda`;
  const testFinalName = `${formattedBase}.Lambda.Tests`;
  const localFinalName = `${formattedBase}.Lambda.Local`;
  const lambdaKey = names(formattedBase).className;
  return {
    base,
    finalName,
    testFinalName,
    localFinalName,
    className: lambdaKey,
    fileName: names(formattedBase).fileName,
    namespace: finalName,
    pascalName: formattedBase,
    lambdaKey,
  };
}

/**
 * Actualiza el archivo appSettings.json para registrar una nueva función Lambda dentro del stack.
 */
function updateAppSettingsJson(
  basePath: string,
  lambdaKey: string,
  name: string,
  memorySize: number,
  namespace: string,
  isNewStack: boolean
) {
  const configPath = path.resolve(
    basePath,
    'cdk',
    'src',
    'config',
    'appSettings.json'
  );
  if (!fs.existsSync(configPath)) return;

  console.log(`📄 Actualizando appSettings.json del cdk: ${configPath}`);
  const json = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const lambdaConfig = {
    Name: names(name.replace(/\./g, '').replace(/lambda$/i, '')).fileName,
    Path: `app/${name}`,
    MemorySize: memorySize,
    Namespace: namespace,
  };

  json.StackElements = json.StackElements || {};
  json.StackElements.LambdaFunctions = json.StackElements.LambdaFunctions || {};

  if (!json.StackElements.LambdaFunctions[lambdaKey]) {
    json.StackElements.LambdaFunctions[lambdaKey] = lambdaConfig;
    console.log(`✅ Lambda agregada al appSettings.json: ${lambdaKey}`);
  } else {
    console.warn(
      `⚠️ Ya existe una lambda con la clave ${lambdaKey}. No se sobrescribió.`
    );
  }

  if (isNewStack) {
    json.Aplication = basePath.split(path.sep).pop()?.toLowerCase();
  }

  fs.writeFileSync(configPath, JSON.stringify(json, null, 2));
}

/**
 * Actualiza el modelo TypeScript del stack para incluir una nueva propiedad correspondiente a la lambda generada.
 */
function updateStackModelLambdaFunctions(basePath: string, lambdaKey: string) {
  const modelPath = path.resolve(
    basePath,
    'cdk',
    'src',
    'model',
    'stackModel.ts'
  );
  console.log(`📄 Actualizando modelo: ${modelPath}`);
  if (!fs.existsSync(modelPath)) return;

  let fileContent = fs.readFileSync(modelPath, 'utf8');

  // 1. Agregar propiedad readonly si no existe
  if (!fileContent.includes(`readonly ${lambdaKey}: LambdaStackModel;`)) {
    fileContent = fileContent.replace(
      /export class LambdaFunctions\s*\{/,
      (match) => `${match}\n  readonly ${lambdaKey}: LambdaStackModel;`
    );
    fs.writeFileSync(modelPath, fileContent);
    console.log(`✅ Propiedad readonly ${lambdaKey} agregada.`);
  }

  // 2. Leer el archivo actualizado
  fileContent = fs.readFileSync(modelPath, 'utf8');

  // 3. Obtener todas las keys actuales
  const matches = [
    ...fileContent.matchAll(/readonly (\w+): LambdaStackModel;/g),
  ];
  const allKeys = matches.map((m) => m[1]);
  console.log(`🔍 Lambdas detectadas en clase: ${allKeys.join(', ')}`);

  // 4. Construir nuevo cuerpo del constructor
  const constructorBody = allKeys
    .map(
      (key) =>
        `    if (!data.${key}) throw new Error('Lambda function "${key}" is required');\n    this.${key} = data.${key};\n`
    )
    .join('');

  // 5. Reemplazar el constructor entero (usando buena regex)
  fileContent = fileContent.replace(
    /constructor\(data: Partial<LambdaFunctions>\)\s*\{[\s\S]*?\}/m,
    `constructor(data: Partial<LambdaFunctions>) {\n${constructorBody}  }`
  );

  fs.writeFileSync(modelPath, fileContent);
  console.log(`✅ stackModel.ts actualizado con todas las lambdas.`);
}

function getCdkStackFolderName(name: string): string {
  return name.trim(); // conserva "LN.SUS.Cobranzas.Deudas.Workflow.Reader" como está
}

export default async function (tree: Tree, options: Options) {
  const slnFile = 'Ln.Sus.Monorepo.Template'; // 👈 tu solution real
  const parsedCdkOption = Number(options.cdkOption);
  const {
    testFinalName,
    localFinalName,
    finalName,
    className,
    fileName,
    namespace,
    pascalName,
    lambdaKey,
  } = normalizeName(options.name);
  const cdkStackFolder = getCdkStackFolderName(options.cdkName);
  const lambdaPath = joinPathFragments(
    'apps',
    cdkStackFolder,
    'app',
    finalName
  );
  const testFinalNamePath = joinPathFragments(
    'apps',
    cdkStackFolder,
    'tests',
    testFinalName
  );

  const localFinalNamePath = joinPathFragments(
    'apps',
    cdkStackFolder,
    'local',
    localFinalName
  );

  const cdkBasePath = joinPathFragments('apps', cdkStackFolder);

  const substitutions = {
    name: finalName,
    className,
    fileName,
    namespace: options.namespace || namespace,
    memorySize: options.memorySize.toString(),
    stackName: names(options.cdkName).className,
    stackNameSpace: `${names(options.cdkName).className}`,
  };

  generateFiles(
    tree,
    joinPathFragments(__dirname, 'files', 'src', '__name__', 'app'),
    lambdaPath,
    substitutions
  );

  generateFiles(
    tree,
    joinPathFragments(__dirname, 'files', 'src', '__name__', 'tests'),
    testFinalNamePath,
    substitutions
  );

  generateFiles(
    tree,
    joinPathFragments(__dirname, 'files', 'src', '__name__', 'local'),
    localFinalNamePath,
    substitutions
  );

  if (parsedCdkOption === 2 && options.cdkName) {
    generateFiles(
      tree,
      joinPathFragments(__dirname, 'files', 'src', '__name__', 'cdk'),
      joinPathFragments(cdkBasePath, 'cdk'),
      substitutions
    );

    const projectJsonPath = joinPathFragments(
      'apps',
      cdkStackFolder,
      'project.json'
    );

    tree.write(
      projectJsonPath,
      JSON.stringify(
        {
          name: names(options.cdkName).className,
          $schema: '../../../node_modules/nx/schemas/project-schema.json',
          projectType: 'library',
          sourceRoot: `apps/${cdkStackFolder}`,
          tags: [],
          targets: {
            build: {
              executor: 'nx:run-commands',
              cache: true,
              dependsOn: ['build:package'],
              options: {
                cwd: `apps/${cdkStackFolder}/cdk`,
                parallel: false,
                commands: [
                  `cdk synth -c configs={args.configs} -c distDir=../../../dist/apps/${cdkStackFolder} -o ../../../dist/apps/${cdkStackFolder}/cdk/`,
                ],
              },
              configurations: {
                dev: { args: '--configs=dev' },
                qa: { args: '--configs=qa' },
                prod: { args: '--configs=qa,prod' },
              },
            },
            'build:package': {
              executor: 'nx:run-commands',
              cache: true,
              dependsOn: ['build:net'],
              options: {
                cwd: `apps/${cdkStackFolder}/app`,
                parallel: false,
                commands: [
                  `mkdir -p ../../../dist/apps/${cdkStackFolder}/app`,
                  `for d in */ ; do echo "📦 Empaquetando Lambda: $d"; mkdir -p ../../../dist/apps/${cdkStackFolder}/app/\${d%/}; dotnet tool install -g Amazon.Lambda.Tools --ignore-failed-sources; export PATH="$HOME/.dotnet/tools:$PATH"; (cd "$d" && dotnet lambda package --output-package "../../../../dist/apps/${cdkStackFolder}/app/\${d%/}/function.zip"); done`,
                ],
              },
            },
            'build:net': {
              executor: 'nx:run-commands',
              cache: true,
              dependsOn: ['build:local'],
              options: {
                cwd: `apps/${cdkStackFolder}/app`,
                parallel: false,
                commands: [
                  'for d in */ ; do echo "⚙️ Compilando Lambda: $d"; dotnet clean "$d"/*.csproj; dotnet build "$d"/*.csproj; done',
                ],
              },
            },
            'build:local': {
              executor: 'nx:run-commands',
              cache: true,
              options: {
                cwd: `apps/${cdkStackFolder}/local`,
                parallel: false,
                commands: [
                  'for d in */ ; do echo "⚙️ Compilando Lambda: $d"; dotnet clean "$d"/*.csproj; dotnet build "$d"/*.csproj; done',
                ],
              },
            },
            tests: {
              executor: 'nx:run-commands',
              cache: true,
              dependsOn: ['build:net'],
              options: {
                cwd: `apps/${cdkStackFolder}/tests`,
                parallel: false,
                commands: [
                  `find . -name '*.csproj' | while read csproj; do echo "🧪 Ejecutando tests: $csproj"; dotnet test "$csproj" --no-build --logger "trx"; done`,
                ],
              },
            },
          },
        },
        null,
        2
      )
    );
  }

  const vscodeDir = path.resolve('.vscode');
  const launchFile = path.join(vscodeDir, 'launch.json');

  const launchConfig = {
    name: `🧪 Debug ${finalName} desde consola`,
    type: 'coreclr',
    request: 'launch',
    env: {
      AWS_PROFILE: 'stg-Suscripciones',
      USE_LOCALSTACK: 'true',
    },
    program:
      '${workspaceFolder}' +
      `/apps/${cdkStackFolder}/local/${finalName}.Local/bin/dev/net8.0/${finalName}.Local.dll`,
    cwd:
      '${workspaceFolder}' +
      `/apps/${cdkStackFolder}/local/${finalName}.Local/bin/dev/net8.0`,
    args: [],
    console: 'integratedTerminal',
    stopAtEntry: false,
  };

  if (!fs.existsSync(vscodeDir)) {
    fs.mkdirSync(vscodeDir);
  }

  let launchJson = { version: '0.2.0', configurations: [] as any[] };
  if (fs.existsSync(launchFile)) {
    launchJson = JSON.parse(fs.readFileSync(launchFile, 'utf8'));
  }

  // No duplicar lanzamientos si ya existe
  if (
    !launchJson.configurations.find((c: any) => c.name === launchConfig.name)
  ) {
    (launchJson.configurations as any[]).push(launchConfig);
    fs.writeFileSync(launchFile, JSON.stringify(launchJson, null, 2));
    console.log(
      `✅ launch.json actualizado para debuggear la Lambda: ${finalName}`
    );
  }

  const lambdaProjectPath = path.join(
    'apps',
    cdkStackFolder,
    'app',
    finalName,
    `${finalName}.csproj`
  );

  const testProjectPath = path.join(
    'apps',
    cdkStackFolder,
    'tests',
    testFinalName,
    `${finalName}.Tests.csproj`
  );

  const localProjectPath = path.join(
    'apps',
    cdkStackFolder,
    'local',
    localFinalName,
    `${finalName}.Local.csproj`
  );

  await formatFiles(tree);
  return () => {
    try {
      updateAppSettingsJson(
        cdkBasePath,
        lambdaKey,
        finalName,
        options.memorySize,
        options.namespace || namespace,
        parsedCdkOption === 2
      );
      updateStackModelLambdaFunctions(cdkBasePath, lambdaKey);
    } catch (error) {
      console.warn(`⚠️ Error al agregar proyectos a la solución: ${error}`);
    }

    try {
      console.log(
        `✅ Lambda ${lambdaProjectPath} sera agregada al Solution .sln`
      );
      execSync(`dotnet sln ${slnFile} add ${lambdaProjectPath}`);
      console.log(`✅ Lambda agregada al Solution .sln`);

      console.log(`✅ Tests ${testProjectPath} sera agregada al Solution .sln`);
      execSync(`dotnet sln ${slnFile} add ${testProjectPath}`);
      console.log(`✅ Tests agregados al Solution .sln`);

      console.log(
        `✅ Local ${localProjectPath} sera agregada al Solution .sln`
      );
      execSync(`dotnet sln ${slnFile} add ${localProjectPath}`);
      console.log(`✅ Local agregados al Solution .sln`);
    } catch (error) {
      console.warn(
        `⚠️ Error al agregar proyectos a la solución .sln: ${error}`
      );
    }
  };
}
