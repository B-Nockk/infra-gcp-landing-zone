locals {
  gcp_regions = {
    # --- Primary EMEA (Best latency via West African subsea cables) ---
    europe-west1 = {
      short = "euw1" # Belgium - Best overall balance of latency, cost, and services
    }
    europe-west4 = {
      short = "euw4" # Netherlands - Massive internet hub, often the cheapest in EU
    }
    europe-west9 = {
      short = "euw9" # Paris - Lowest CO2 footprint, extremely fast connection to WA
    }
    europe-southwest1 = {
      short = "eusw1" # Madrid - Geographically closest European region
    }
    europe-west2 = {
      short = "euw2" # London - Historic peering hub for African ISPs
    }
    europe-west3 = {
      short = "euw3" # Frankfurt - Standard enterprise choice
    }
    africa-south1 = {
      short = "afs1" # Johannesburg - Only African region (routing can sometimes be longer than EU)
    }

    # --- Primary US / Global Defaults ---
    us-east1 = {
      short = "use1" # South Carolina - Closest US region across the Atlantic
    }
    us-central1 = {
      short = "usc1" # Iowa - The GCP baseline (new services launch here first)
    }

    # --- Middle East ---
    me-west1 = {
      short = "mew1" # Tel Aviv - Geographically close alternative
    }
  }
}
