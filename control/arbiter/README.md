# Priority Arbiter

## Overview

A parameterized **priority arbiter** that examines multiple request signals and grants access to the **highest-priority requester**.

The highest-index request has the highest priority. Only one grant can be active at a time.

## Features

* Parameterized number of requesters
* Fixed priority
* Highest-index request has highest priority
* One-hot grant output
* Combinational implementation
* Fully synthesizable

## Parameters

| Parameter | Default | Description                         |
| --------- | ------: | ----------------------------------- |
| `WIDTH`   |       4 | Number of request and grant signals |

## Interface

| Signal  | Direction |   Width | Description       |
| ------- | --------- | ------: | ----------------- |
| `req`   | Input     | `WIDTH` | Request signals   |
| `grant` | Output    | `WIDTH` | Granted requester |

## Functionality

The arbiter scans `req` from `WIDTH-1` down to `0`.

The first asserted request receives the grant.

For `WIDTH = 4`:

| `req`  | `grant` |
| ------ | ------- |
| `0000` | `0000`  |
| `0001` | `0001`  |
| `0010` | `0010`  |
| `0101` | `0100`  |
| `1010` | `1000`  |
| `1111` | `1000`  |

For example:

```text
req   = 4'b0101
grant = 4'b0100
```

Both requesters `2` and `0` are active, but requester `2` has higher priority.

## Implementation

The design uses a `for` loop that scans from the most significant bit to the least significant bit.

A `priority_flag` tracks whether a request has already been granted:

1. `grant` is initialized to zero.
2. Requests are checked from highest to lowest priority.
3. The first active request sets the corresponding grant bit.
4. `priority_flag` prevents any lower-priority request from receiving a grant.

This guarantees that `grant` is either all zeros or one-hot.

## Example

```systemverilog id="a4q5tz"
logic [7:0] req;
logic [7:0] grant;

arbiter #(
    .WIDTH(8)
) dut (
    .req   (req),
    .grant (grant)
);
```

## Notes

* The arbiter is purely combinational.
* No clock or reset is required.
* The highest-index request always has the highest priority.
* At most one bit of `grant` can be asserted.
* If no request is active, `grant` is `0`.
