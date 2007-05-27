#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Common Public License (CPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
require File.dirname(__FILE__) + '/../test_helper'

class TestRunTest < Test::Unit::TestCase
  def test_create_from_gzipped
    do_create_from_test("#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz")
  end

  def test_create_from
    do_create_from_test("#{RAILS_ROOT}/test/fixtures/data/Report.xml")
  end

  def do_create_from_test(filename)
    upload_time = Time.now
    test_run = TestRunBuilder.create_from('myhostname', filename, User.find(1), upload_time)
    assert_not_nil(test_run)

    assert_equal( 'tiny', test_run.name )
    assert_equal( 12200, test_run.revision )
    assert_equal( "2007-05-20T10:50:50Z", test_run.occured_at.getutc.xmlschema )
    assert_equal( upload_time.getutc.xmlschema, test_run.uploaded_at.getutc.xmlschema )
    assert_equal( 'myhostname', test_run.host.name )
    assert_equal( 1, test_run.uploader_id )
    assert_equal( 1, test_run.uploader.id )

    assert_equal( 'ia32-linux', test_run.build_target.name )
    assert_equal( 7, test_run.build_target.params.size )
    assert_equal( 'ia32', test_run.build_target.params['target.arch'])
    assert_equal( '32', test_run.build_target.params['target.address.size'])
    assert_equal( 'Linux', test_run.build_target.params['target.os'])
    assert_equal( '0x5B000000', test_run.build_target.params['target.bootimage.code.address'])
    assert_equal( '0x57000000', test_run.build_target.params['target.bootimage.data.address'])
    assert_equal( '0x5E000000', test_run.build_target.params['target.bootimage.rmap.address'])
    assert_equal( '0xb0000000', test_run.build_target.params['target.max-mappable.address'])

    assert_equal( 2, test_run.build_runs.size )
    test_run.build_runs.each do |br|
      if br.build_configuration.name == 'prototype'
        assert_equal( 111037, br.time )
        assert_equal( 'SUCCESS', br.result )
        assert_equal( true, br.output.include?('/target/prototype_ia32-linux/') )
      else
        assert_equal( 78607, br.time )
        assert_equal( 'SUCCESS', br.result )
        assert_equal( true, br.output.include?('/target/prototype-opt_ia32-linux/') )
      end
    end

    configs = test_run.build_runs.collect {|br| br.build_configuration}
    assert_equal( 2, configs.size )
    configs.each do |c|
      if c.name == 'prototype'
        assert_equal( 'prototype', c.name )
        assert_equal( 13, c.params.size)
        assert_equal( 'base', c.params['config.runtime.compiler'])
        assert_equal( 'base', c.params['config.bootimage.compiler'])
        assert_equal( 'org.mmtk.plan.generational.marksweep.GenMS', c.params['config.mmtk.plan'])
        assert_equal( 'false', c.params['config.include.aos'])
        assert_equal( 'false', c.params['config.include.gcspy'])
        assert_equal( '${config.include.gcspy-stub}', c.params['config.include.gcspy-stub'])
        assert_equal( '1', c.params['config.include.gcspy-client'])
        assert_equal( 'false', c.params['config.include.all-classes'])
        assert_equal( 'normal', c.params['config.assertions'])
        assert_equal( '20', c.params['config.default-heapsize.initial'])
        assert_equal( '100', c.params['config.default-heapsize.maximum'])
        assert_equal( '', c.params['config.bootimage.compiler.args'])
        assert_equal( '0', c.params['config.stress-gc-interval'])
      else
        assert_equal( 'prototype-opt', c.name )
        assert_equal( 13, c.params.size)
        assert_equal( 'opt', c.params['config.runtime.compiler'])
        assert_equal( 'base', c.params['config.bootimage.compiler'])
        assert_equal( 'org.mmtk.plan.generational.marksweep.GenMS', c.params['config.mmtk.plan'])
        assert_equal( 'true', c.params['config.include.aos'])
        assert_equal( 'false', c.params['config.include.gcspy'])
        assert_equal( '${config.include.gcspy-stub}', c.params['config.include.gcspy-stub'])
        assert_equal( '1', c.params['config.include.gcspy-client'])
        assert_equal( 'false', c.params['config.include.all-classes'])
        assert_equal( 'normal', c.params['config.assertions'])
        assert_equal( '50', c.params['config.default-heapsize.initial'])
        assert_equal( '100', c.params['config.default-heapsize.maximum'])
        assert_equal( '', c.params['config.bootimage.compiler.args'])
        assert_equal( '0', c.params['config.stress-gc-interval'])
      end
    end
    assert_equal( 2, test_run.test_configurations.size )
    test_run.test_configurations.each do |tc|
      if tc.name == 'prototype'
        assert_equal( 'prototype', tc.name)
        assert_equal( 2, tc.params.size)
        assert_equal( '', tc.params['mode'])
        assert_equal( '', tc.params['extra.args'])
        assert_equal( 2, tc.groups.size )
        tc.groups.each do |g|
          if g.name == 'basic'
            assert_equal( 'basic', g.name )
            assert_equal( 49, g.test_cases.size )
            assert_equal( 45, g.successes.size )
            assert_equal( 3, g.failures.size )
            assert_equal( 1, g.excludes.size )

            test_case = nil
            g.test_cases.each { |tc| test_case = tc if tc.name == 'ImageSizes' }
            assert_not_nil(test_case)
            test_case = TestCase.find(test_case.id)
            assert_equal( 'ImageSizes', test_case.name )
            assert_equal( 'SUCCESS', test_case.result )
            assert_equal( 0, test_case.exit_code )
            assert_equal( 446, test_case.time )
            assert_equal( 'test.org.jikesrvm.basic.stats.JikesImageSizes', test_case.classname )
            assert_equal( '/home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/RVM.code.image /home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/RVM.data.image /home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/RVM.rmap.image', test_case.args )
            assert_equal( '/home/peter/Research/clean_jikesrvm/target/tests/tiny/prototype/basic', test_case.working_directory )
            assert_equal( '/home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/rvm -X:vm:errorsFatal=true -X:processors=all -Xms20M -Xmx150M    -classpath "/home/peter/Research/clean_jikesrvm/target/tests/tiny/prototype/basic/classes" test.org.jikesrvm.basic.stats.JikesImageSizes /home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/RVM.code.image /home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/RVM.data.image /home/peter/Research/clean_jikesrvm/dist/prototype_ia32-linux/RVM.rmap.image', test_case.command )
            assert_equal( "Code Size: 2938156\nData Size: 14243924\nRmap Size: 329907\nTotal Size: 17511987\n", test_case.output )

            assert_equal( 6, test_case.params.size)
            assert_equal( '20', test_case.params['initial.heapsize'])
            assert_equal( '150', test_case.params['max.heapsize'])
            assert_equal( '400', test_case.params['time.limit'])
            assert_equal( '', test_case.params['extra.args'])
            assert_equal( 'all', test_case.params['processors'])
            assert_equal( '', test_case.params['max.opt.level'])

            assert_equal( 4, test_case.statistics.size)
            assert_equal( '2938156', test_case.statistics['code.size'])
            assert_equal( '14243924', test_case.statistics['data.size'])
            assert_equal( '329907', test_case.statistics['rmap.size'])
            assert_equal( '17511987', test_case.statistics['total.size'])
          else
            assert_equal( 'opttests', g.name )
            assert_equal( 1, g.test_cases.size )
            assert_equal( 1, g.successes.size )
            assert_equal( 0, g.failures.size )
            assert_equal( 0, g.excludes.size )
          end
        end
      else
        assert_equal( 'prototype-opt', tc.name)
        assert_equal( 2, tc.params.size)
        assert_equal( '', tc.params['mode'])
        assert_equal( '', tc.params['extra.args'])
        assert_equal( 2, tc.groups.size )
        tc.groups.each do |g|
          if g.name == 'basic'
            assert_equal( 'basic', g.name )
            assert_equal( 49, g.test_cases.size )
            assert_equal( 45, g.successes.size )
            assert_equal( 3, g.failures.size )
            assert_equal( 1, g.excludes.size )
          else
            assert_equal( 'opttests', g.name )
            assert_equal( 1, g.test_cases.size )
            assert_equal( 1, g.successes.size )
            assert_equal( 0, g.failures.size )
            assert_equal( 0, g.excludes.size )
          end
        end
      end
    end
  end
end