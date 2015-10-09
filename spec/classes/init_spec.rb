require 'spec_helper'
describe 'role_treebase' do

  context 'with defaults for all parameters' do
    it { should contain_class('role_treebase') }
  end
end
