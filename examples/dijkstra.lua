--[[
 calculate and return the shortest length and a shortest path between
 the Ith and Jth vertices of G, a connected simple graph

 Input: G is represented by an adjacency matrix with entries being the
 weight. 0 or negative weight indicates no edge between two vertices.

 by David Wang, dwang at liberty dot edu, on 04/16/2025 Wednesday
--]]
require 'mathly';

function Dijkstra(G, I, J)
  local n = #G
  if I <= 0 or I > n or J <= 0 or J > n then
    error('Dijkstra(G, i, j): i, j must be in the range from 1 to ' .. tostring(n))
  end
  if I == J then return 0, {I} end

  local S = {{{I}, 0}} -- {{shortest path1, length}, ...} where a path = {c, ..., b, a} for a -> b -> ... -> c
  local S1 = seq(n)    -- S1[i] == i; S1 U {terminal point of each path in S} = {vertices of G}
  S1[I] = 0            -- delete vertex I

  local index, vertex, minlen
  while true do
    minlen = nil
    for i = 1, #S do       -- examine every neighbors of S that are in S1
      local v = S[i][1][1] -- S[i][1] is a path, S[i][2] is the length of the path
      for j = 1, #S1 do
        if S1[j] > 0 and G[v][j] > 0 then -- vertex j is a neighbor of vertex v
          local len = S[i][2] + G[v][j]
          if minlen == nil or len < minlen then
            index, vertex, minlen = i, j, len
          end
        end
      end
    end
    if vertex == J then
      table.insert(S[index][1], 1, vertex)
      return minlen, reverse(S[index][1])
    else
      local p = copy(S[index][1])
      local v = p[1]           -- path S[index][1] may be deletable
      table.insert(p, 1, vertex)
      S[#S + 1] = {p, minlen}
      -- disp(S)               -- remove the leading '--' to show the process
      S1[vertex] = 0           -- delete the vertex from S1

      local noneighbors = true -- clean up S, important for large G
      for i = 1, #S1 do
        if S1[i] > 0 and G[v][i] > 0 then noneighbors = false; break end
      end
      if noneighbors then table.remove(S, index) end
    end
  end
end

---------------------------- test ----------------------------
-- Exampl 1
G1 = {  -- Section 10.6 Figure 3
  {0, 4, 0, 2, 0, 0},
  {4, 0, 3, 0, 3, 0},
  {0, 3, 0, 0, 0, 2},
  {2, 0, 0, 0, 3, 0},
  {0, 3, 0, 3, 0, 1},
  {0, 0, 2, 0, 1, 0}
}
labels = {'a', 'b', 'c', 'd', 'e', 'z'} -- corresponding to 1, 2, 3, 4, 5, 6
len, path = Dijkstra(G1, 6, 1)
disp(len) -- 6
disp(map(function(i) return labels[i] end, path)) -- {'z', 'e', 'd', 'a'}


-- Exampl 2
G2 = {  -- Section 10.6 Figure 4
  {0, 4,  2, 0,  0, 0},
  {4, 0,  1, 5,  0, 0},
  {2, 1,  0, 8, 10, 0},
  {0, 5,  8, 0,  2, 6},
  {0, 0, 10, 2,  0, 3},
  {0, 0,  0, 6,  3, 0}
}

labels = {'a', 'b', 'c', 'd', 'e', 'z'} -- corresponding to 1, 2, 3, 4, 5, 6
len, path = Dijkstra(G2, 1, 6)
disp(len) -- 13
disp(map(function(i) return labels[i] end, path)) -- {'a', 'c', 'b', 'd', 'e', 'z'}

len, path = Dijkstra(G2, 3, 6)
disp(len) -- 11
disp(map(function(i) return labels[i] end, path)) -- {'c', 'b', 'd', 'e', 'z'}
