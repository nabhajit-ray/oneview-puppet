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

provider_class = Puppet::Type.type(:oneview_server_profile).provider(:oneview_server_profile)

describe provider_class, unit: true, if: login[:api_version] >= 300 do
  api_version = login[:api_version] || 200
  resource_name = 'ServerProfile'
  resourcetype = Object.const_get("OneviewSDK::API#{api_version}::Synergy::#{resource_name}") unless api_version < 300
  fake_json_response = File.read('spec/support/fixtures/unit/provider/server_profile.json')

  include_context 'shared context'

  let(:resource) do
    Puppet::Type.type(:oneview_server_profile).new(
      name: 'Server Profile',
      ensure: 'present',
      data:
          {
            'name' => 'Profile',
            'serverHardwareUri' => '/rest/server-hardware/37333036-3831-584D-5131-303030323037'
          },
      provider: 'synergy'
    )
  end

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  let(:test) { resourcetype.new(@client, resource['data']) }

  before(:each) do
    allow(resourcetype).to receive(:find_by).and_return([test])
    provider.exists?
  end

  context 'given the minimum parameters before server creation' do
    it 'should be an instance of the provider synergy' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_server_profile).provider(:synergy)
    end

    it 'should raise error when server is not found' do
      allow(resourcetype).to receive(:find_by).and_return([])
      expect { provider.found }.to raise_error(/No ServerProfile with the specified data were found on the Oneview Appliance/)
    end

    it 'should be able to create the resource' do
      allow(resourcetype).to receive(:find_by).and_return([])
      allow_any_instance_of(resourcetype).to receive(:create).and_return(test)
      expect(provider.exists?).to eq(false)
      expect(provider.create).to be
    end

    it 'should be able to perform the patch update' do
      allow_any_instance_of(resourcetype).to receive(:update_from_template).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.update_from_template).to be
    end

    it 'should be able to get available targets' do
      allow(resourcetype).to receive(:get_available_targets).with(anything, nil).and_return(fake_json_response)
      expect(provider.get_available_targets).to be
    end

    it 'should be able to get the compliance preview' do
      allow_any_instance_of(resourcetype).to receive(:get_compliance_preview).and_return(fake_json_response)
      expect(provider.get_compliance_preview).to be
    end

    it 'should be able to get available networks' do
      allow_any_instance_of(resourcetype).to receive(:get_available_networks).and_return(fake_json_response)
      expect(provider.get_available_networks).to be
    end

    it 'should be able to get the transformation' do
      allow_any_instance_of(resourcetype).to receive(:get_transformation).and_return(fake_json_response)
      expect(provider.get_transformation).to be
    end

    it 'should be able to get messages' do
      allow_any_instance_of(resourcetype).to receive(:get_messages).and_return(fake_json_response)
      expect(provider.get_messages).to be
    end

    it 'should be able to get available servers' do
      allow(resourcetype).to receive(:get_available_servers).and_return(fake_json_response)
      expect(provider.get_available_servers).to be
    end

    it 'should be able to get profile ports' do
      allow(resourcetype).to receive(:get_profile_ports).and_return(fake_json_response)
      expect(provider.get_profile_ports).to be
    end

    it 'should delete the server profile' do
      expect_any_instance_of(resourcetype).to receive(:delete).and_return(true)
      expect(provider.destroy).to be
    end

    it 'should be able to get a sas logical jbod by name' do
      allow(resourcetype).to receive(:get_sas_logical_jbod).and_return(true)
      expect(provider.get_sas_logical_jbods).to be
    end

    it 'should be able to get_sas_logical_jbod_drives for a server profile' do
      allow(resourcetype).to receive(:get_sas_logical_jbod_drives).and_return(true)
      expect(provider.get_sas_logical_jbod_drives).to be
    end

    it 'should be able to get a sas logical jbod attachment by name' do
      allow(resourcetype).to receive(:get_sas_logical_jbod_attachment).and_return(true)
      expect(provider.get_sas_logical_jbod_attachments).to be
    end
  end

  context 'given the available storage systems query parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_server_profile).new(
        name: 'Server Profile',
        ensure: 'get_available_networks',
        data:
            {
              # 'name' => 'Profile',
              'query_parameters' => {
                'enclosureGroupUri'     => '/rest/fake',
                'storageSystemId'       => '/rest/fake',
                'serverHardwareTypeUri' => '/rest/fake'
              }
            },
        provider: 'synergy'
      )
    end

    it 'should successfully get an available storage system' do
      allow(resourcetype).to receive(:get_available_storage_system).and_return(true)
      expect(provider.get_available_storage_system).to be
    end

    it 'should successfully get_available_storage_systems' do
      allow(resourcetype).to receive(:get_available_storage_systems).and_return(true)
      expect(provider.get_available_storage_systems).to be
    end

    it 'should successfully get_available_networks' do
      allow(resourcetype).to receive(:get_available_networks).and_return(true)
      provider.exists?
      expect(provider.get_available_networks).to be
    end

    it 'should be able to get all sas logical jbod' do
      allow(resourcetype).to receive(:get_sas_logical_jbods).and_return(true)
      expect(provider.get_sas_logical_jbods).to be
    end

    it 'should be able to get all sas logical jbod attachment' do
      allow(resourcetype).to receive(:get_sas_logical_jbod_attachments).and_return(true)
      expect(provider.get_sas_logical_jbod_attachments).to be
    end
  end
end
