package cup.aug;

import java.util.ArrayList;
import java.util.List;

public class Node<String> {
	private String value = null;
	private List<Node<String>> children = new ArrayList<>();
	private Node<String> parent = null;
	
	public Node(String value) {
		this.value = value;
	}
	
	public Node<String> addChild(Node<String> child) {
		child.setParent(this);
		this.children.add(0, child);
		return child;
	}
	
	public Node<String> addChildAtLastPosition(Node<String> child) {
		child.setParent(this);
		this.children.add(child);
		return child;
	}
	
	public void addChildren(List<Node<String>> children) {
		children.forEach(child -> child.setParent(this));
		this.children.addAll(children);
	}
	
	public List<Node<String>> getChildren() {
		return this.children;
	}
	
	public void setParent(Node<String> parent) {
		this.parent = parent;
	}
	
	public Node<String> getParent() {
		return this.parent;
	}
	
	public void setValue(String value) {
		this.value = value;
	}
	
	public String getValue() {
		return this.value;
	}
	
}
