/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
module.exports = {
  Sidebar: [
    'get_started',
    'concepts',
    'usecases',
    'roadmap',
    {
      type: 'category',
      label: 'Codegen',
      items: [
        'codegen/annotation',
        'codegen/generators',
      ]
    },
    {
      type: 'category',
      label: 'Designer',
      items: [
        'designer/overview',
        'designer/pages',
        'designer/widget_designer',
        'designer/api_docs',
      ]
    },
    {
      type: 'category',
      label: 'Official examples',
      items: [
        'official_examples/demo_example',
      ]
    },
    'contribute',
  ],
};
