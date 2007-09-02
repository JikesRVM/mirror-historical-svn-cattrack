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

class TestRunBuilderTest < Test::Unit::TestCase
  def test_create_from_gzipped
    do_create_from_test("#{RAILS_ROOT}/test/fixtures/import_data/Report.xml.gz")
  end

  def test_create_from
    do_create_from_test("#{RAILS_ROOT}/test/fixtures/import_data/Report.xml")
  end

  def do_create_from_test(input_filename)
    test_run = TestRunBuilder.create_from(input_filename)
    assert_not_nil(test_run)

    assert_equal( 'tiny', test_run.name )
    assert_equal( 'tiny-sse', test_run.variant )
    assert_equal( 12200, test_run.revision )
    assert_equal( "2007-05-20T05:50:50Z", test_run.start_time.getutc.xmlschema )
    #assert_equal( "2007-05-20T10:50:50Z", test_run.start_time.getutc.xmlschema )
    #assert_equal( "2007-05-20T20:50:50Z", test_run.end_time.getutc.xmlschema )
    assert_equal( 'rvmx86lnx32.anu.edu.au', test_run.host.name )

    assert_equal( 'ia32-linux', test_run.build_target.name )
    assert_equal( 7, test_run.build_target.params.size )
    assert_equal( 'ia32', test_run.build_target.params['arch'] )
    assert_equal( '32', test_run.build_target.params['address.size'] )
    assert_equal( 'Linux', test_run.build_target.params['os'] )
    assert_equal( '0x5B000000', test_run.build_target.params['bootimage.code.address'] )
    assert_equal( '0x57000000', test_run.build_target.params['bootimage.data.address'] )
    assert_equal( '0x5E000000', test_run.build_target.params['bootimage.rmap.address'] )
    assert_equal( '0xb0000000', test_run.build_target.params['max-mappable.address'] )

    assert_equal( 2, test_run.build_configurations.size )
    c = test_run.build_configurations[0]
    assert_equal( 'prototype', c.name )
    assert_equal( 5, c.params.size )
    assert_equal( 'prototype', c.params['variant'] )
    assert_equal( 'base', c.params['runtime.compiler'] )
    assert_equal( 'base', c.params['bootimage.compiler'] )
    assert_equal( 'org.mmtk.plan.generational.marksweep.GenMS', c.params['mmtk.plan'] )
    assert_equal( 'false', c.params['include.aos'] )
    assert_equal( 78607, c.time )
    assert_equal( 'FAILURE', c.result )
    assert_equal( '...', c.output )

    c = test_run.build_configurations[1]
    assert_equal( 'prototype-opt', c.name )
    assert_equal( 5, c.params.size )
    assert_equal( 'prototype-opt', c.params['variant'] )
    assert_equal( 'opt', c.params['runtime.compiler'] )
    assert_equal( 'base', c.params['bootimage.compiler'] )
    assert_equal( 'org.mmtk.plan.generational.marksweep.GenMS', c.params['mmtk.plan'] )
    assert_equal( 'false', c.params['include.aos'] )
    assert_equal( 78607, c.time )
    assert_equal( 'SUCCESS', c.result )
    assert_equal( '...', c.output )

    assert_equal( 1, c.test_configurations.size)
    tc = c.test_configurations[0]
    assert_equal( 'default', tc.name )
    assert_equal( 2, tc.params.size )
    assert_equal( '', tc.params['mode'] )
    assert_equal( '', tc.params['extra.args'] )

    assert_equal( 1, tc.groups.size )
    g = tc.groups[0]
    assert_equal( 'basic', g.name )

    assert_equal( 1, g.test_cases.size )

    test_case = g.test_cases[0]
    assert_equal( 'ImageSizes', test_case.name )
    assert_equal( 'cd /home/peter/Research/clean_jikesrvm/target/tests/tiny/prototype-opt/basic && /home/peter/Research/clean_jikesrvm/dist/prototype-opt_ia32-linux/rvm -X:vm:errorsFatal=true -X:processors=all -Xms50M -Xmx150M    -classpath "/home/peter/Research/clean_jikesrvm/target/tests/tiny/prototype-opt/basic/classes" test.org.jikesrvm.basic.stats.JikesImageSizes /home/peter/Research/clean_jikesrvm/dist/prototype-opt_ia32-linux/RVM.code.image /home/peter/Research/clean_jikesrvm/dist/prototype-opt_ia32-linux/RVM.data.image /home/peter/Research/clean_jikesrvm/dist/prototype-opt_ia32-linux/RVM.rmap.image', test_case.command )
    assert_equal( 6, test_case.params.size)
    assert_equal( '50', test_case.params['initial.heapsize'])
    assert_equal( '150', test_case.params['max.heapsize'])
    assert_equal( '400', test_case.params['time.limit'])
    assert_equal( '', test_case.params['extra.args'])
    assert_equal( 'all', test_case.params['processors'])
    assert_equal( '', test_case.params['max.opt.level'])

    assert_equal( 2, test_case.test_case_executions.size )

    test_case_execution = test_case.test_case_executions[0]
    assert_equal( 'default', test_case_execution.name )
    assert_equal( 0, test_case_execution.exit_code )
    assert_equal( 'SUCCESS', test_case_execution.result )
    assert_equal( '', test_case_execution.result_explanation )
    assert_equal( 2303, test_case_execution.time )
    assert_equal( "Code Size: 7100184\nData Size: 23482080\nRmap Size: 565623\nTotal Size: 31147887\n", test_case_execution.output )

    assert_equal( 1, test_case_execution.statistics.size)
    assert_equal( 'Boo!', test_case_execution.statistics['myTextStatistic'] )
    assert_equal( 4, test_case_execution.numerical_statistics.size)
    assert_equal( '7100184', test_case_execution.numerical_statistics['code.size'].to_s )
    assert_equal( '23482080', test_case_execution.numerical_statistics['data.size'].to_s )
    assert_equal( '565623', test_case_execution.numerical_statistics['rmap.size'].to_s )
    assert_equal( '31147887', test_case_execution.numerical_statistics['total.size'].to_s )

    test_case_execution = test_case.test_case_executions[1]
    assert_equal( 'default_not', test_case_execution.name )
    assert_equal( 16, test_case_execution.exit_code )
    assert_equal( 'FAILURE', test_case_execution.result )
    assert_equal( 'Bad exit code', test_case_execution.result_explanation )
    assert_equal( 2303, test_case_execution.time )
    assert_equal( "Oh no! Beta!", test_case_execution.output )

    assert_equal( 0, test_case_execution.statistics.size)
    assert_equal( 0, test_case_execution.numerical_statistics.size)
  end
end
