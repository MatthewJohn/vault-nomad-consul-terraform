resource "nomad_scheduler_config" "this" {
  scheduler_algorithm             = "binpack"
  memory_oversubscription_enabled = true
  preemption_config = {
    system_scheduler_enabled   = true
    batch_scheduler_enabled    = false
    service_scheduler_enabled  = false
    sysbatch_scheduler_enabled = false
  }
}