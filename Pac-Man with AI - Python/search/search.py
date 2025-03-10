# search.py
# ---------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in searchAgents.py).
"""

import util
from game import Directions
from typing import List

class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
        """
        Returns the start state for the search problem.
        """
        util.raiseNotDefined()

    def isGoalState(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raiseNotDefined()

    def getSuccessors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, stepCost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'stepCost' is
        the incremental cost of expanding to that successor.
        """
        util.raiseNotDefined()

    def getCostOfActions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raiseNotDefined()




def tinyMazeSearch(problem: SearchProblem) -> List[Directions]:
    """
    Returns a sequence of moves that solves tinyMaze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tinyMaze.
    """
    s = Directions.SOUTH
    w = Directions.WEST
    return  [s, s, w, s, w, w, s, w]

def depthFirstSearch(problem: SearchProblem) -> List[Directions]:


    """
    Search the deepest nodes in the search tree first.

    Your search algorithm needs to return a list of actions that reaches the
    goal. Make sure to implement a graph search algorithm.

    To get started, you might want to try some of these simple commands to
    understand the search problem that is being passed in:

    print("Start:", problem.getStartState())
    print("Is the start a goal?", problem.isGoalState(problem.getStartState()))
    print("Start's successors:", problem.getSuccessors(problem.getStartState()))
    """
    "*** YOUR CODE HERE ***"

    stack = util.Stack()
    visited = set()
    stack.push((problem.getStartState(), []))
    while not stack.isEmpty():
        node = stack.pop()
        if problem.isGoalState(node[0]):
            return node[1]
        else:
            if node[0] not in visited:
                visited.add(node[0])
                for successor in problem.getSuccessors(node[0]):
                    path=node[1] + [successor[1]]
                    stack.push((successor[0], path))
    return []




def breadthFirstSearch(problem: SearchProblem) -> List[Directions]:
    "*** YOUR CODE HERE ***"
    queue = util.Queue()
    visited = set()
    queue.push((problem.getStartState(),[]))
    visited.add(problem.getStartState())

    while not queue.isEmpty():
        node = queue.pop()
        if problem.isGoalState(node[0]):
            return node[1]
        for successor in problem.getSuccessors(node[0]):
            if successor[0] not in visited:
                visited.add(successor[0])
                path=node[1] + [successor[1]]
                queue.push((successor[0],path))
    return []


def uniformCostSearch(problem: SearchProblem) -> List[Directions]:
    """Search the node of least total cost first."""
    "*** YOUR CODE HERE ***"
    queue = util.PriorityQueue()
    visited = set()
    start_state = problem.getStartState()
    queue.push((start_state, []), 0)

    while not queue.isEmpty():
        node = queue.pop()

        if problem.isGoalState(node[0]):
            return node[1]

        if node[0] not in visited:
            visited.add(node[0])
            for successor in problem.getSuccessors(node[0]):
                if successor[0] not in visited:
                    cost=problem.getCostOfActions(node[1]+[successor[1]])
                    queue.push((successor[0], node[1]+[successor[1]]), cost)
    return []



def nullHeuristic(state, problem=None) -> float:
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0

def aStarSearch(problem: SearchProblem, heuristic=nullHeuristic) -> List[Directions]:
    """Search the node that has the lowest combined cost and heuristic first."""
    "*** YOUR CODE HERE ***"
    queue = util.PriorityQueue()
    start_state= problem.getStartState()
    queue.push((start_state, []), 0)

    best_cost = {start_state: 0}

    while not queue.isEmpty():
        node=queue.pop()
        if problem.isGoalState(node[0]):
            return node[1]

        for successor in problem.getSuccessors(node[0]):
            cost = problem.getCostOfActions(node[1] + [successor[1]])
            if successor[0] not in best_cost or cost < best_cost[successor[0]]:
                best_cost[successor[0]] = cost
                queue.push((successor[0], node[1] + [successor[1]]), cost + heuristic(successor[0], problem))
    return []

# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
