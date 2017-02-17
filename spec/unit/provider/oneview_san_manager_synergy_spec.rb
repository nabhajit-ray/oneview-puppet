################################################################################
# (C) Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

require 'spec_helper'
require_relative '../../support/fake_response'
require_relative '../../shared_context'

provider_class = Puppet::Type.type(:oneview_san_manager).provider(:synergy)
resourcetype = OneviewSDK::SANManager

describe provider_class, unit: true do
  include_context 'shared context'

  @resourcetype = resourcetype
  context 'given the min parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_san_manager).new(
        name: 'san_manager',
        ensure: 'found',
        data:
            {
              'providerDisplayName' => 'Brocade Network Advisor'
            },
        provider: 'synergy'
      )
    end

    let(:provider) { resource.provider }

    let(:instance) { provider.class.instances.first }

    it 'should be an instance of the provider Synergy' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_san_manager).provider(:synergy)
    end

    it 'should raise error when San Manager is not found' do
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([])
      provider.exists?
      expect { provider.found }.to raise_error(/No SANManager with the specified data were found on the Oneview Appliance/)
    end

    context 'given the create parameters' do
      let(:resource) do
        Puppet::Type.type(:oneview_san_manager).new(
          name: 'san_manager',
          ensure: 'present',
          data:
              {
                'providerDisplayName' => 'Brocade Network Advisor',
                'connectionInfo' => [
                  {
                    'name' => 'Host',
                    'value' => '172.18.15.1'
                  },
                  {
                    'name' => 'Port',
                    'value' => 5989
                  },
                  {
                    'name' => 'Username',
                    'value' => 'dcs'
                  },
                  {
                    'name' => 'Password',
                    'value' => 'dcs'
                  },
                  {
                    'name' => 'UseSsl',
                    'value' => true
                  }
                ]
              },
          provider: 'synergy'
        )
      end

      it 'should create/add the san manager' do
        test = resourcetype.new(@client, resource['data'])
        expect(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([])
        expect(resourcetype).to receive(:find_by).with(anything, 'providerDisplayName' => resource['data']['providerDisplayName'])
          .and_return([])
        provider.exists?
        allow_any_instance_of(resourcetype).to receive(:add).and_return(test)
        expect(provider.create).to be
      end

      it 'should update the san manager' do
        test = resourcetype.new(@client, resource['data'])
        expect(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([])
        expect(resourcetype).to receive(:find_by).with(anything, 'providerDisplayName' => resource['data']['providerDisplayName'])
          .and_return([test])
        provider.exists?
        expect(provider.create).to be
      end

      it 'should parse provider uri the san manager' do
        test = resourcetype.new(@client, resource['data'])
        expect(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([])
        expect(resourcetype).to receive(:find_by).with(anything, 'providerDisplayName' => resource['data']['providerDisplayName'])
          .and_return([test])
        provider.exists?
        expect(provider.create).to be
      end
    end

    context 'given the minimum parameters after San Manager creation' do
      before(:each) do
        resource['data']['uri'] = '/rest/san-managers/fake'
        test = resourcetype.new(@client, resource['data'])
        allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
        allow(resourcetype).to receive(:get_all).with(anything).and_return([test])
        provider.exists?
      end

      it 'should be able to run through self.instances' do
        allow_any_instance_of(resourcetype).to receive(:find_by)
        expect(instance).to be
      end

      it 'should delete the san manager' do
        expect_any_instance_of(OneviewSDK::Client).to receive(:rest_delete).and_return(FakeResponse.new('uri' => '/rest/fake'))
        expect(provider.destroy).to be
      end
    end
  end
end