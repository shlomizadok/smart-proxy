require 'test_helper'

class PluginTest < Test::Unit::TestCase
  class TestPlugin2 < Proxy::Plugin; plugin :test2, '1.0'; end
  def test_http_rackup_returns_empty_string_with_missing_rackup_path
    assert_equal "", TestPlugin2.http_rackup
    assert_equal "", TestPlugin2.https_rackup
  end

  class TestPlugin10 < Proxy::Plugin; plugin :test10, '1.0'; end
  def test_enable_of_only_http_is_successful
    TestPlugin10.load_test_settings(:enabled => 'http')
    assert TestPlugin10.http_enabled?
    assert !TestPlugin10.https_enabled?
  end

  class TestPlugin11 < Proxy::Plugin; plugin :test11, '1.0'; end
  def test_enable_of_only_https_is_successful
    TestPlugin11.load_test_settings(:enabled => 'https')
    assert TestPlugin11.https_enabled?
    assert !TestPlugin11.http_enabled?
  end

  class TestPlugin12 < Proxy::Plugin
    http_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
    https_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))

    default_settings :enabled => 'https'
    plugin :test12, '1.0'
  end
  def test_plugin_loads_http_rack_path
    assert !TestPlugin12.http_enabled?
    assert TestPlugin12.https_enabled?
    assert_equal :test12, TestPlugin12.plugin_name

    # Ensure that the content is read from 'http_config.ru'
    File.stubs(:read).returns("require 'test12/test12_api'")

    assert_equal TestPlugin12.http_rackup, ''
    assert_equal "require 'test12/test12_api'", TestPlugin12.https_rackup
  end

  class TestBundlerGroupPlugin < ::Proxy::Plugin
    plugin :test_bundler_group, '1.0'
    bundler_group :test_group
  end
  def test_bundler_group_name_returns_specified_bundler_group
    assert_equal :test_group, TestBundlerGroupPlugin.bundler_group_name
  end

  class TestDefaultBundlerGroupPlugin < ::Proxy::Plugin
    plugin :test_default_bundler_group, '1.0'
  end
  def test_default_bundler_group
    assert_equal :test_default_bundler_group, TestDefaultBundlerGroupPlugin.bundler_group_name
  end

  class TestPluginWithAfterActivationBlock < ::Proxy::Plugin
    after_activation do
      "after_activation was called"
    end
  end
  def test_uses_legacy_module_initializer_if_after_activation_block_is_present
    assert_equal ::Proxy::LegacyModuleLoader, TestPluginWithAfterActivationBlock.module_loader_class
  end

  class TestPluginWithoutAfterActivationBlock < ::Proxy::Plugin; end
  def test_uses_default_module_initializer_if_after_activation_block_not_present
    assert_equal ::Proxy::DefaultModuleLoader, TestPluginWithoutAfterActivationBlock.module_loader_class
  end

  class TestLoadClasses; def load_classes; end; end
  class TestLoadClassesViaClassPlugin < ::Proxy::Plugin
    load_classes TestLoadClasses
  end
  def test_class_loader_can_use_class
    assert TestLoadClassesViaClassPlugin.class_loader.instance_of?(TestLoadClasses)
  end

  class TestLoadClassesViaClassNamePlugin < ::Proxy::Plugin
    load_classes "::PluginTest::TestLoadClasses"
  end
  def test_class_loader_can_use_class_name
    assert TestLoadClassesViaClassNamePlugin.class_loader.instance_of?(TestLoadClasses)
  end

  class TestLoadClassesViaBlockPlugin < ::Proxy::Plugin
    load_classes { "noop" }
  end
  def test_class_loader_can_use_a_block
    assert TestLoadClassesViaBlockPlugin.class_loader.respond_to?(:load_classes)
  end

  class TestPluginWithoutLoadClasses < ::Proxy::Plugin; end
  def test_class_loader_returns_nil_if_load_classes_was_omitted
    assert_nil TestPluginWithoutLoadClasses.class_loader
  end

  class ProgrammableSettingsClass; end
  class TestProgrammableSettingsWithClassPlugin < ::Proxy::Plugin
    load_programmable_settings ProgrammableSettingsClass
  end
  def test_programmable_settings_can_use_class
    assert TestProgrammableSettingsWithClassPlugin.programmable_settings.instance_of?(ProgrammableSettingsClass)
  end

  class TestProgrammableSettingsWithClassNamePlugin < ::Proxy::Plugin
    load_programmable_settings "::PluginTest::ProgrammableSettingsClass"
  end
  def test_programmable_settings_can_use_class_name
    assert TestProgrammableSettingsWithClassNamePlugin.programmable_settings.instance_of?(ProgrammableSettingsClass)
  end

  class TestProgrammableSettingsWithBlockPlugin < ::Proxy::Plugin
    load_programmable_settings {|container, settings| "noop" }
  end
  def test_programmable_settings_can_use_a_block
    assert TestProgrammableSettingsWithBlockPlugin.programmable_settings.respond_to?(:load_programmable_settings)
  end

  class TestPluginWithNoProgrammableSettings < ::Proxy::Plugin; end
  def test_programmable_settings_return_nil_when_omitted
    assert_nil TestPluginWithNoProgrammableSettings.programmable_settings
  end

  class DiWiringsClass; end
  class TestDiWiringsWithClassPlugin < ::Proxy::Plugin
    load_dependency_injection_wirings DiWiringsClass
  end
  def test_di_wirings_can_use_class
    assert TestDiWiringsWithClassPlugin.di_wirings.instance_of?(DiWiringsClass)
  end

  class TestDiWiringsWithClassNamePlugin < ::Proxy::Plugin
    load_dependency_injection_wirings "::PluginTest::DiWiringsClass"
  end
  def test_di_wirings_can_use_class_name
    assert TestDiWiringsWithClassNamePlugin.di_wirings.instance_of?(DiWiringsClass)
  end

  class TestDiWiringsWithBlockPlugin < ::Proxy::Plugin
    load_dependency_injection_wirings {|container, settings| "noop"}
  end
  def test_di_wirings_can_use_a_block
    assert TestDiWiringsWithBlockPlugin.respond_to?(:load_dependency_injection_wirings)
  end

  class TestPluginWithoutDiWirings < ::Proxy::Plugin; end
  def test_di_wirings_return_nil_if_omitted
    assert_nil TestPluginWithoutDiWirings.di_wirings
  end

  class FakeValidator; end
  class TestCustomValidatorsPlugin < ::Proxy::Plugin
    load_validators :a_validator => FakeValidator
  end
  def test_custom_validators_returns_specified_mappings
    assert_equal({:a_validator => FakeValidator}, TestCustomValidatorsPlugin.custom_validators)
  end

  class TestPluginWithoutCustomValidators < ::Proxy::Plugin; end
  def test_custom_validators_returns_empty_hash_if_mappings_were_omitted
    assert TestPluginWithoutCustomValidators.custom_validators.empty?
  end
end