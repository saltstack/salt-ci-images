runprep-dist:
  cmd.run:
    - name: '. /root/.nvm/nvm.sh; nvm use 0.10; ./prep_dist.py'
    - cwd: /root/halite
    - failhard: True


run-nose:
  cmd.run:
    - name: '. /root/.nvm/nvm.sh; nvm use 0.10; export PYTHONPATH=/root/halite/halite; nosetests --with-xunit --xunit-file /root/halite_test_results.xml'
    - cwd: /root/halite
    - failhard: True
