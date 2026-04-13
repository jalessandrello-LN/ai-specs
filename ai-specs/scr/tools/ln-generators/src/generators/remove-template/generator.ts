import { Tree, formatFiles, joinPathFragments, names } from '@nx/devkit';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

interface Options {
  name: string;
}

export default async function (tree: Tree, options: Options) {
  const nameParts = names(options.name);
  console.log(`✅ Direccion: ${options.name}`);

  const projectRoot = joinPathFragments('apps', options.name);
  const slnFile = 'Ln.Sus.Monorepo.Template.sln';

  // Buscar todos los .csproj bajo apps/{listener}/src/**/*
  const csprojPaths: string[] = [];
  const searchCsproj = (dir: string) => {
    console.log(`✅ Direccion: ${dir}`);

    if (!fs.existsSync(dir)) return;
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      console.log(`✅ Proyecto Encontrado ${nameParts}: ${fullPath}`);
      if (entry.isDirectory()) {
        searchCsproj(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.csproj')) {
        csprojPaths.push(fullPath);
      }
    }
  };

  searchCsproj(path.join(projectRoot, 'src'));

  for (const proj of csprojPaths) {
    try {
      execSync(`dotnet sln ${slnFile} remove "${proj}"`);
      console.log(`✅ Proyecto eliminado del .sln: ${proj}`);
    } catch (err) {
      console.warn(`⚠️ Error al remover ${proj} del .sln`, err);
    }
  }

  // Eliminar launch config
  const launchPath = path.join('.vscode', 'launch.json');
  if (fs.existsSync(launchPath)) {
    const launchJson = JSON.parse(fs.readFileSync(launchPath, 'utf8'));
    launchJson.configurations = launchJson.configurations.filter(
      (c: any) => c.name !== `${nameParts.fileName}`
    );
    fs.writeFileSync(launchPath, JSON.stringify(launchJson, null, 2));
    console.log('✅ launch.json actualizado');
  }

  // Eliminar tasks relacionadas
  const tasksPath = path.join('.vscode', 'tasks.json');
  if (fs.existsSync(tasksPath)) {
    const tasksJson = JSON.parse(fs.readFileSync(tasksPath, 'utf8'));
    tasksJson.tasks = tasksJson.tasks.filter(
      (task: any) => !task.label.includes(nameParts.fileName)
    );
    fs.writeFileSync(tasksPath, JSON.stringify(tasksJson, null, 2));
    console.log('✅ tasks.json actualizado');
  }

  // Eliminar carpeta completa del listener
  if (fs.existsSync(projectRoot)) {
    fs.rmSync(projectRoot, { recursive: true, force: true });
    console.log(`🗑️ Carpeta eliminada: ${projectRoot}`);
  }

  await formatFiles(tree);
}
