===============================================
Tempest Integration of community image tests
===============================================

------------
Installation
------------
Make sure that you have installed the `tempest package <https://github.com/openstack/tempest>`_

Once installed, tempest will automatically discover the installed plugins.
Simply clone the repository in your machine and install the package:

.. code-block:: bash

    $ cd community_image_tests
    $ sudo pip install -e .

---------------------
How to run the tests
---------------------
1. Set the parameters in `tempest.conf <http://docs.openstack.org/developer/tempest/sampleconf.html>`_


   Required:

   .. code-block:: bash

     [compute]
     image_ref = <image id of the community image>

   Optional:

   .. code-block:: bash

     [image]
     catalog_type = image
     endpoint_type = publicURL

2. Validate if Tempest has discovered the test in the plugin:

   .. code-block:: bash

    $ testr list-tests | grep community_image_tests_tempest_plugin

   You will get an output like:

   .. code-block:: bash

    2016-11-04 16:34:56.313 30187 INFO tempest [-] Using tempest config file /Users/sayyub/temp/etc/tempest.conf
    ...
    community_image_tests_tempest_plugin.tests.scenario.test_community_image.TestCommunityImage.test_minimum_basic_scenario[compute,id-a94ff412-062d-4327-b345-df69cb7ea1aa,network]

3. Run the test case:

   .. code-block:: bash

    $ testr run community_image_tests_tempest_plugin.tests.scenario.test_community_image.TestCommunityImage.test_minimum_basic_scenario
