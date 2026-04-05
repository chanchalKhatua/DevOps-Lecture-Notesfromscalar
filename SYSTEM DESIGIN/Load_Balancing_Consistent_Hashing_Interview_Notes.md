# Load Balancing & Consistent Hashing — Interview-Ready Notes

---

## TABLE OF CONTENTS
1. [Scaling: Vertical vs Horizontal](#1-scaling-vertical-vs-horizontal)
2. [DNS Resolution](#2-dns-resolution)
3. [Load Balancer (LB)](#3-load-balancer-lb)
4. [Load Balancing Algorithms](#4-load-balancing-algorithms)
5. [Database Scaling & Sharding](#5-database-scaling--sharding)
6. [Hashing Basics](#6-hashing-basics)
7. [Problem with Naive Hashing](#7-problem-with-naive-hashing)
8. [Consistent Hashing](#8-consistent-hashing)
9. [Virtual Nodes (VNodes)](#9-virtual-nodes-vnodes)
10. [Adding / Removing a Node in Consistent Hashing](#10-adding--removing-a-node-in-consistent-hashing)
11. [Interview Quick-Fire Q&A](#11-interview-quick-fire-qa)
12. [Cheat Sheet Summary](#12-cheat-sheet-summary)

---

## 1. Scaling: Vertical vs Horizontal

### Vertical Scaling ("Scale Up")
- Replace the existing machine with a **bigger, more powerful** one (more CPU cores, RAM, HDD).
- **Pros:** Simple to maintain; single machine — no distributed system complexity.
- **Cons:**
  - Gets **exponentially expensive** at higher specs. Example: cost(8 × 64 GB machines) << cost(1 × 512 GB machine).
  - After a certain point, **physically impossible** to scale further — hardware has limits.
  - **SPOF (Single Point of Failure):** If the one machine goes down, the entire system is down.

### Horizontal Scaling ("Scale Out")
- Add **more commodity machines** (cheaper, standard hardware) and distribute load across them.
- **Pros:**
  - Much more cost-effective at scale.
  - No theoretical ceiling — just keep adding nodes.
  - Fault tolerant — losing one node doesn't kill the system.
- **Cons:** Requires distributed system design — load balancing, data sharding, network coordination.

> **Interview Tip:** Always mention SPOF when asked about vertical scaling. Then pivot to horizontal scaling as the industry standard. Real-world systems (Google, Amazon, Meta) are almost entirely horizontally scaled.

---

## 2. DNS Resolution

**DNS = "Universal Hashmap" → domainName → IP address (or list of IPs)**

### Flow when a user types a URL:
```
User's Browser → Browser Cache → ISP DNS → Root Server → TLD Server (.com, .net, ...) → Authoritative DNS → IP returned
```

### Key Concepts
| Term | Meaning |
|---|---|
| **ICANN** | Non-profit body that manages domain name registry (source of truth) |
| **Root Servers** | 13 root server clusters globally; entry point to DNS hierarchy |
| **TLD Server** | Handles top-level domains (.com, .net, .in, etc.) |
| **Authoritative DNS** | Stores actual domain → IP mapping for a given domain |
| **ISP DNS / Resolver** | Your ISP's DNS resolver — caches results to reduce load |
| **Browser Cache** | Fastest lookup; cached IP from previous visits |

### Why DNS Scales
- DNS does **not** have every query reach the root/TLD servers — most are resolved by the **ISP DNS cache**.
- The number of queries that actually reach a TLD server is a tiny fraction of total DNS queries.
- DNS uses **TTL** on records — caches are refreshed periodically, not on every request.

### DNS and Load Balancing
- A single domain name can return **a list of IPs** (multiple servers), enabling DNS-level load balancing.
- Limitation: DNS caches are sticky — a client might keep hitting the same IP for the duration of the TTL even if that server is down.

---

## 3. Load Balancer (LB)

### What is it?
A **computer/server** that sits in front of your backend servers and runs **load balancing algorithms** to route incoming requests.

```
Client → [Load Balancer] → Server 1
                        → Server 2
                        → Server 3
```

### What does an LB do?
- **Distributes** incoming requests across available servers (not necessarily equally).
- **Health checks** (heartbeat): Periodically pings backend servers to verify they're alive. Removes dead servers from the pool.
- **Monitors** response times, CPU load, connection count, etc. (for smart LBs).

### Can the LB itself be a SPOF?
**Yes — if it's a single machine.** Solutions:
- Deploy **multiple LBs** in active-active or active-passive configuration.
- Use **DNS round-robin** across multiple LB IPs.
- Use cloud LBs (AWS ALB/ELB, GCP Load Balancer) which are inherently distributed and managed.

> **Interview Tip:** Always address LB as a potential SPOF. Show you know how to mitigate it.

### Types of Load Balancers
| Type | Layer | Example |
|---|---|---|
| L4 (Transport Layer) | TCP/UDP | AWS NLB |
| L7 (Application Layer) | HTTP/HTTPS, can route by URL path, headers, cookies | AWS ALB, Nginx |

---

## 4. Load Balancing Algorithms

### 4.1 Round Robin (RR)
Requests are sent to servers in a **circular sequence**: S1 → S2 → S3 → S1 → S2 → ...
- **Best for:** Stateless servers with similar capacity.
- **Problem:** Ignores server load/capacity differences.

### 4.2 Weighted Round Robin
Assign a **weight** to each server based on capacity.
- Example: Weights 1:1:2 → S1 gets 1 request, S2 gets 1 request, S3 gets 2 requests.
- Pattern: `[S1, S2, S3, S3, S1, S2, S3, S3, ...]`
- **Best for:** Heterogeneous server fleet.

### 4.3 Least Response Time
Route request to the server with the **lowest current response time**.
- Requires LB to actively track response latencies.
- **Best for:** Latency-sensitive systems.

### 4.4 Least Connections
Route to the server with the **fewest active connections**.
- **Best for:** Long-lived connections (WebSocket, streaming).

### 4.5 IP Hash
Hash the client's IP → deterministically route to the same server every time.
- Provides **session stickiness** (same client → same server).
- **Problem:** Uneven distribution if many clients share an IP (NAT). Also breaks if server count changes.

### 4.6 Smart LB (ML-based)
- Uses ML algorithms to predict optimal server routing.
- Considers: health checks, response time, CPU/memory, historical patterns.
- Used by large-scale systems.

> **Interview Tip:** Know at least 3 algorithms and their trade-offs. Most follow-up questions will be: *"What happens when a server goes down?"* — Answer: Health check detects it, LB removes it from rotation.

---

## 5. Database Scaling & Sharding

### Why Shard?
At scale, a single DB machine **runs out of storage** and **cannot handle all read/write load**.

### Sharding = Partitioning data across multiple DB machines.

### Step 1: Choose a Sharding Key
The sharding key determines which rows stay together on the same shard.

**Example — Del.icio.us (bookmarking app):**
- If you shard by `site_url`: `getAllBookmarks(userId)` must query ALL shards → slow.
- If you shard by `user_id`: All bookmarks for a user are on one shard → efficient.

> **Rule:** Choose a sharding key such that **the most common query touches only one shard**.

### Step 2: Shard Routing Algo — userId → shard

---

## 6. Hashing Basics

A hash function maps an input `x` to an output `y`:
```
fn(x) → y
```
Properties of a good hash function:
- **Deterministic:** Same input always gives same output.
- **Non-reversible:** `fn(y) → x` should not be possible.
- **Uniform distribution:** Outputs are spread evenly across the range.
- **Fast to compute.**

Example: `hash(userId) = (sum of ASCII values of userId) % N`

---

## 7. Problem with Naive Hashing

### Naive Approach: `shard = userId % number_of_shards`

**With 4 shards:**
```
user_id 6  → 6 % 4 = 2 → DB3
user_id 1  → 1 % 4 = 1 → DB2
user_id 4  → 4 % 4 = 0 → DB1
```
✅ Even distribution, ✅ O(1) lookup

**Add a 5th shard — now `userId % 5`:**
```
user_id 16 → 16 % 4 = 0 → DB1   (old)
user_id 16 → 16 % 5 = 1 → DB2   (new) ← data is on DB1, but query goes to DB2 ❌
```

**The problem:** When `N` changes, **almost every mapping changes** → massive **data redistribution** across all shards → huge downtime, network cost, and complexity.

> This is the fundamental problem Consistent Hashing solves.

---

## 8. Consistent Hashing

### Core Idea
Instead of a fixed modulo, place both **servers** and **data keys** on the same circular **hash ring** (hash space `0` to `N`).

```
Hash ring:  0 ────────────── N (wraps back to 0)
```

### How it works:
1. Define a hash space `[0, N]` (e.g., 0–99 for simplicity, or `[0, 2^32 - 1]` in practice).
2. **Hash each server's identifier** (e.g., IP address) → place server at that position on the ring.
3. **Hash each data item's identifier** (e.g., userId, email) → place data at that position on the ring.
4. **Assignment rule:** Each data item is assigned to the **first server encountered going clockwise** from the data's position on the ring.

### Example (hash space 0–99):
```
Ring positions: 0 ........ 20 (DB1) ........ 45 (DB2) ........ 70 (DB3) ........ 95 (DB4) .... 99/0
```
- `hash(Vinod) = 12` → clockwise → first server is DB1 (at 20) → **Vinod stored in DB1**
- `hash(Neha) = 56` → clockwise → first server is DB3 (at 70) → **Neha stored in DB3**
- `hash(Sangana) = 3` → clockwise → first server is DB1 (at 20) → **Sangana stored in DB1**
- `hash(Varshit) = 10` → clockwise → first server is DB1 (at 20) → **Varshit stored in DB1**

### Adding a New Server (DB5 added at position 25):
- Only the data items that were between position 20 and 25 (previously going to DB1) now go to DB5.
- **All other data items are unaffected.**
- This is O(K/N) data moved, where K = total keys, N = number of servers.

### Removing / Failing a Server (DB3 at 70 fails):
- Data items that were going to DB3 now go to DB4 (next clockwise server).
- **Only DB3's data is affected, not the entire system.**

### Why it's better:
| | Naive Hashing | Consistent Hashing |
|---|---|---|
| Add server | Remap ~all keys | Remap ~K/N keys |
| Remove server | Remap ~all keys | Remap only that server's keys |
| Distribution | Even | Roughly even (better with VNodes) |
| Lookup complexity | O(1) | O(log N) via binary search on sorted ring |

### Implementation (sorted array approach):
```python
# Servers are placed on ring and stored in a sorted array
ring = [(20, "DB1"), (45, "DB2"), (70, "DB3"), (95, "DB4")]

def get_server(key):
    h = hash(key)
    # Binary search for first server position >= h
    for pos, server in ring:
        if h <= pos:
            return server
    return ring[0][1]  # wrap around to first server
```

---

## 9. Virtual Nodes (VNodes)

### The Problem with Basic Consistent Hashing
When a server is removed (say DB3 at position 70), **all its load** goes to the **next single server** (DB4 at 95). DB4 now handles double load → potential cascading failure.

### Root Cause
Basic consistent hashing guarantees each server handles `1/N` of the load on average, but **removal shifts the entire load to one neighbor**, not distributed.

### Solution: Virtual Nodes
Each physical server is represented by **multiple points** on the ring using multiple hash functions (or by appending indexes like DB1.1, DB1.2, DB1.3).

```
DB1 → DB1.1, DB1.2, DB1.3  (3 virtual nodes on the ring)
DB2 → DB2.1, DB2.2, DB2.3
DB3 → DB3.1, DB3.2, DB3.3
```

### Ring with Virtual Nodes:
```
Ring: [DB3.1, DB1.1, (Neha), DB2.1, (Vinod), DB1.3, DB3.2, DB2.2, DB1.2, DB3.3, ...]
```

### What happens when DB3 is removed?
- DB3.1's range → goes to DB1.1 (next clockwise VNode) → load absorbed by DB1
- DB3.2's range → goes to DB2.2 → load absorbed by DB2
- DB3.3's range → goes to DB1.2 → load absorbed by DB1

**DB3's load is spread across DB1 and DB2 — not all on one server!** ✅

### What happens when a new server DB4 is added?
- DB4's 3 virtual nodes (DB4.1, DB4.2, DB4.3) are hashed to 3 positions on the ring.
- Each virtual node takes a small slice from its predecessor → load redistributed from **multiple existing servers**, not one.

### VNode Benefits
- **Uniform load distribution** across all servers.
- **Failure is graceful** — load spreads across remaining servers, not cascading.
- **Adding servers eases load from multiple servers**, not just one neighbor.
- The more VNodes per server, the more even the distribution.

> **Interview Tip:** VNodes are how DynamoDB, Cassandra, and most production consistent hashing implementations actually work. Saying "we use virtual nodes with X replicas per server" will impress interviewers.

---

## 10. Adding / Removing a Node in Consistent Hashing

### Adding a Node (e.g., DB4 with virtual nodes DB4.1, DB4.2, DB4.3):

1. Hash DB4.1, DB4.2, DB4.3 → place on ring.
2. For each new VNode, identify which existing server previously owned that range.
3. **Only move data** that now falls between the new VNode and its predecessor on the ring.
4. No other data moves.

### Removing a Node (e.g., DB3 dies):

1. Remove DB3.1, DB3.2, DB3.3 from the ring.
2. Each virtual node's range is now owned by the next clockwise VNode.
3. DB3's data needs to be re-fetched/re-routed from replication or remapped.

### Real-world: Replication
In practice (Cassandra, DynamoDB), each key is **replicated** to the next `R` servers clockwise on the ring (replication factor = R). So when a server dies, **data is not lost** — it's already on the next servers.

---

## 11. Interview Quick-Fire Q&A

**Q: What is a Load Balancer?**
A computer that runs load balancing algorithms to route incoming requests across a pool of servers. It performs health checks and removes failed servers from rotation.

**Q: Can a Load Balancer be a SPOF?**
Yes. Mitigated by running multiple LBs (active-active), using DNS round-robin across LB IPs, or using managed cloud LBs.

**Q: What's the difference between L4 and L7 Load Balancers?**
L4 (Transport) operates at TCP/UDP level — fast but dumb. L7 (Application) understands HTTP — can route by URL path, headers, cookies — more flexible but slightly more overhead.

**Q: What is consistent hashing and why do we need it?**
Consistent hashing is a technique to distribute data across servers such that when a server is added or removed, only `K/N` keys need to be remapped (K = keys, N = servers), instead of almost all keys as in naive modulo hashing.

**Q: What is the problem with `userId % N` for sharding?**
When N changes (server added or removed), the mapping changes for almost every key, causing massive data redistribution and downtime.

**Q: How does adding a server in consistent hashing work?**
The new server is placed on the ring via its hash. Only the data between the new server and its predecessor on the ring needs to move to it. All other data stays in place.

**Q: What is a virtual node and why is it used?**
A virtual node is one of several positions on the hash ring assigned to a single physical server. Multiple VNodes per server ensure that when a server fails, its load is distributed across many remaining servers rather than overloading one neighbor.

**Q: What sharding key would you choose for a social media app?**
`user_id` — ensures all posts, likes, and comments for a user are co-located on the same shard, making per-user queries efficient.

**Q: What is the difference between Round Robin and Weighted Round Robin?**
Round Robin cycles requests evenly across all servers. Weighted Round Robin assigns more requests to servers with higher capacity (weight).

**Q: How does a Load Balancer know a server is down?**
Via **health checks** — periodic heartbeat pings (HTTP, TCP). If a server fails N consecutive health checks, it's removed from the rotation.

**Q: What is Least Response Time algorithm?**
The LB tracks the response time of recent requests to each server and routes new requests to the server currently responding fastest.

---

## 12. Cheat Sheet Summary

```
VERTICAL SCALING
  ├── Bigger machine
  ├── Simple but has SPOF & cost ceiling
  └── Not used at scale

HORIZONTAL SCALING
  ├── More commodity machines
  ├── Needs: LB + Sharding + Distributed data
  └── Industry standard at scale

LOAD BALANCER
  ├── Round Robin          → equal distribution, O(1)
  ├── Weighted RR          → heterogeneous fleet
  ├── Least Response Time  → latency-sensitive
  ├── Least Connections    → long-lived connections
  ├── IP Hash              → session stickiness
  └── Smart LB (ML)        → adaptive routing

NAIVE SHARDING (userId % N)
  ├── Works fine when N is fixed
  └── BREAKS when N changes → full redistribution

CONSISTENT HASHING
  ├── Hash ring [0, N]
  ├── Servers placed by hash(server_id)
  ├── Data placed by hash(data_id)
  ├── Assignment: clockwise to first server
  ├── Add server → only K/N keys move
  └── Remove server → only that server's keys reassigned

VIRTUAL NODES
  ├── Each server = multiple points on ring (e.g., DB1.1, DB1.2, DB1.3)
  ├── Failure spreads load across all servers, not one neighbor
  ├── More VNodes = more uniform distribution
  └── Used by: Cassandra, DynamoDB, Amazon S3
```

---

*Sources: Class handwritten notes (Load Balancing & Consistent Hashing, 09/03/26) + System Design Notes — December Evening Batch*
