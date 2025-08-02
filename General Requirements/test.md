graph LR
  subgraph DC2[Datacenter 2 - TO BE FAILED]
    FCI1[FCI Node 1] --> FCI[(FCI Cluster)]
    FCI2[FCI Node 2] --> FCI
  end

  subgraph DC1[Datacenter 1]
    AG1[AG Node] --> AG[[AlwaysOn AG]]
  end

  FCI -- Primary Replica --> AG
  AG -- Sync Replication --> AG1

  subgraph DC3[Datacenter 3]
    FSW[[File Share Witness]]
  end

  AG1 <-. Quorum Vote .-> FSW
  FCI <-. Quorum Vote .-> FSW
