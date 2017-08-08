def upgrade ta, td, a, d
  a["corosync"]["ring_mode"] = \
      ta["corosync"]["ring_mode"]
  a["corosync"]["second_ring_network"] = \
      ta["corosync"]["second_ring_network"]
  return a, d
end

def downgrade ta, td, a, d
  a["corosync"].delete("ring_mode")
  a["corosync"].delete("second_ring_network")
  return a, d
end
