#
# C45.jl - Decision Trees for Julia
# 
# This file implements decision trees in a fairly straight-forward manner compliant with the 
# C4.5 algorithm. The goal is to provide a framework to make decision trees with more than 
# two child nodes in cases where there are discrete attributes, unlike the DecisionTree.jl 
# package. 
#
# This package is inspired by the DecisionTree.jl package, and Prof. Sean Luke's AI lectures 
# during the 2013 Fall semester at GMU. This is actually a port of my original Common Lisp
# with extensions taken from the DecisionTree package.

module C45

using DataFrames

export DTLeaf, DTInternal, information, gini

# abstract type for internal node use
abstract DTNode

# Empty node class, for constructors
type EmptyNode <: DTNode
end

# Leaf node
type DTLeaf <: DTNode
	majority::Any
	values:Vector
end

# internal node
type DTInternal <: DTNode
	featid::Integer
	evl::Function # should return the index of the appropriate node given a value in the domain of the feature
	children::Vector{DTNode}
	
	DTInternal() = new(0,def_choice,Vector(DTNode,1))
end

# A wrapper around DataFrame to add labels to data.
# Note that labels can have NA as a value.
type LabeledData
	data::DataFrame
	labels::Array
end


function def_choice(array::Vector)
	array[rand(1:length(array))]
end

# getColumn - A function to...get a column from a matrix
# Inputs:
#	a - the3 array to get the folumn from
#	col - the column number, index starting at 1
#
# Output:
#	vec - A column vector from a at index col
#
function getColumn(a::Array, col::Integer)
	if 2 < dims(a) || dims(a) < 2
		throw(ArgumentError())
	end
	
	if col < 1
		throw(ArgumentError())
	end
	
	rows = size(a,1)
	vec = Array(eltype(a), rows, 1)
	
	for i in 1:rows
		vec[i] = a[i, col]
	end
	
	return vec
end

# log_2 - a function to handle the undefined case of log2(0)
# Inputs:
#	x - the input value
# Outputs:
#	Outputs either 0 if x == 0, or log2(x)
function log_2(x)
	if x == 0
		return x
	else
		return log2(x)
	end
end

# countAppearances - a function to see how many times something appears in something else
# Inputs:
#	a - the array object to search through
#	thing - what you are searching for
#
# Output:
#	count - the integer of the number of times thing appeared in a
function countAppearances(a::Array, thing)
	count = 0
	for e in a
		if a == thing
			count += 1
		end
	end
	return count
end

# information - the function to calculate the information content as per information theory
# Inputs:
#	probabilities - the data array, should be a column vector
# Outputs:
#	sum - the information contained in the probability distribution
function information(probabilities::Array)
	sum = 0.0
	for i in probabilities
		sum += (i * log_2(i))
	end
	return (sum * -1)
end

# gini - calculates the GINI coefficient for a list of probabilities
# Inputs:
#	probabilities - a list of probabilities, should sum to 1
# Outputs:
#	the gini coefficient.
function gini(probabilities::Array)
	sum = 0.0
	for p in probabilities
		sum += p^2
	end
	return (1 - sum)
end

# Note that the labels NEED to be in the same order.
#function genProbabilities(feature::Array, samples::Array, labels::Array, vals::Array=unique(samples))
#	data = getColumn(samples, feature[1])
#	if feature[2] == "discrete"
#		counts = map(x -> countAppearance(samples, x), vals)
		pos_counts = Array(eltype(samples), size(samples,1))
#		for s in 1:size(samples,1)
			
		end
#	else
#	
#	end
#end

function chooseFeature(features::Array, samples::Array, evl::Function = information)
	best = Array(Any,2)
	best[2] = 0
	best[1] = 0
	for f in features
		probs = genProbabilities(f, samples)
		if evl(probs) > best[2]
			best[1] = f
			best[2]=evl(probs)
		end
	end
	return best[1]
end

function choosePivot(samples::Array, evl::Function=information,  labels::Array)
	end = size(samples,1) - 1
	pivots = Array(eltype(samples),end)
	for i in 1:end
		pivot[i] = (samples[i] + samples[i+1]) / 2
	end
	
	best = [NA,0]
	for p in pivots
		probs = genProbabilities(samples. labels)
		res = evl(probs)
		if res > best[2]
			best[1] = p
			best[2] = res
		end
	end
	return best[1]
end