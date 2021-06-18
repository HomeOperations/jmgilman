output "uuid" {
  description = "UUID of the VM"
  value       = vsphere_virtual_machine.vm.*.uuid
}