################################################################################
# (C) Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

require 'spec_helper'

provider_class = Puppet::Type.type(:oneview_datacenter).provider(:synergy)
api_version = login[:api_version] || 200

describe provider_class, unit: true, if: api_version >= 300 do
  include_context 'shared context'
  resourcetype = OneviewSDK.resource_named(:Datacenter, api_version, 'Synergy')

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  let(:test) { resourcetype.new(@client, resource['data']) }

  context 'given the create parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_datacenter).new(
        name: 'Datacenter',
        ensure: 'present',
        data:
            {
              'name' => 'Datacenter',
              'width' => '5000',
              'depth' => '5000'
            },
        provider: 'synergy'
      )
    end

    it 'should be an instance of the provider Ruby' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_datacenter).provider(:synergy)
    end

    it 'should return that the resource does not exists' do
      allow(resourcetype).to receive(:find_by).and_return([])
      expect(provider.exists?).not_to be
    end

    it 'should create/add the datacenter' do
      expect(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([])
      expect(resourcetype).to receive(:find_by).with(anything, 'name' => resource['data']['name'])
        .and_return([])
      provider.exists?
      allow_any_instance_of(resourcetype).to receive(:add).and_return(test)
      expect(provider.create).to be
    end
  end

  context 'given the min parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_datacenter).new(
        name: 'Datacenter',
        ensure: 'found',
        provider: 'synergy'
      )
    end

    it 'should not return any datacenters' do
      allow(resourcetype).to receive(:find_by).and_return([])
      expect(provider.exists?).not_to be
      expect { provider.found }.to raise_error(/No Datacenter with the specified data were found on the Oneview Appliance/)
    end
  end

  context 'given the min parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_datacenter).new(
        name: 'Datacenter',
        ensure: 'present',
        data:
            {
              'name' => 'Datacenter'
            },
        provider: 'synergy'
      )
    end

    before(:each) do
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      provider.exists?
    end

    it 'should be able to get the visual content' do
      visual_content = 'spec/support/fixtures/unit/provider/datacenter_visual_content.json'
      allow_any_instance_of(resourcetype).to receive(:get_visual_content).and_return(File.read(visual_content))
      expect(provider.get_visual_content).to eq(true)
    end

    it 'deletes the resource' do
      resource['data']['uri'] = '/rest/fake'
      test = resourcetype.new(@client, resource['data'])
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      allow(resourcetype).to receive(:find_by).with(anything, 'name' => resource['data']['name']).and_return([test])
      expect_any_instance_of(OneviewSDK::Client).to receive(:rest_delete).and_return(FakeResponse.new('uri' => '/rest/fake'))
      provider.exists?
      expect(provider.destroy).to be
    end
  end
end
