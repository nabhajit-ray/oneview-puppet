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

require 'oneview-sdk'

Puppet::Type.newtype(:oneview_rack) do
  desc "Oneview's Rack Bundle"

  ensurable do
    defaultvalues
    # :nocov:
    # Get Methods
    newvalue(:found) do
      provider.found
    end

    newvalue(:get_device_topology) do
      provider.get_device_topology
    end

    newvalue(:add_rack_resource) do
      provider.add_rack_resource
    end

    newvalue(:remove_rack_resource) do
      provider.remove_rack_resource
    end
    # :nocov:
  end

  newparam(:name, namevar: true) do
    desc 'Rack name'
  end

  newparam(:data) do
    desc 'Rack data hash'
    validate do |value|
      raise Puppet::Error, 'Inserted value for data is not valid' unless value.class == Hash
    end
  end
end
