import { createTreeWithEmptyWorkspace } from '@nx/devkit/testing';
import { Tree, readProjectConfiguration } from '@nx/devkit';

import { addListenerGenerator } from './generator';
import { AddListenerGeneratorSchema } from './schema';

describe('tools/ln-generators/src/generators/add-listener generator', () => {
  let tree: Tree;
  const options: AddListenerGeneratorSchema = { name: 'test' };

  beforeEach(() => {
    tree = createTreeWithEmptyWorkspace();
  });

  it('should run successfully', async () => {
    await addListenerGenerator(tree, options);
    const config = readProjectConfiguration(tree, 'test');
    expect(config).toBeDefined();
  });
});
